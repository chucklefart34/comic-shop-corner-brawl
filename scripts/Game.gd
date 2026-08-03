extends Control

# ----------------------------
# STATE
# ----------------------------
var deck: Array = []
var discard: Array = []
var hand: Array = []
var player_can_act := true

var selected_hero_index: int = -1
var selected_attack: String = ""

var enemy_hp: int = 0
var enemy_max_hp: int = 0

# ----------------------------
# UI
# ----------------------------
@onready var hp_label = $UI/TopBar/HPLabel
@onready var fight_label = $UI/TopBar/FightLabel

@onready var token_label = $UI/TopBar/TokenLabel

@onready var enemy_hp_label = $UI/EnemyArea/EnemyHPLabel

@onready var info_label = $UI/InfoLabel

@onready var hero_buttons = [
	$UI/HeroArea/HeroButton1,
	$UI/HeroArea/HeroButton2,
	$UI/HeroArea/HeroButton3
]

@onready var attack_a_btn = $UI/AttackArea/AttackAButton
@onready var attack_b_btn = $UI/AttackArea/AttackBButton
@onready var end_turn_btn = $UI/EndTurnButton


# ----------------------------
# INIT
# ----------------------------
func _ready():
	randomize()
	connect_button_sounds(self)
	setup_hit_vignette()

	deck = RunData.deck.duplicate()
	deck.shuffle()

	for btn in hero_buttons:
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		btn.custom_minimum_size = Vector2(140, 180)

	start_fight()

	for i in hero_buttons.size():
		var idx = i
		hero_buttons[i].pressed.connect(func(): select_hero(idx))

	attack_a_btn.pressed.connect(func():
		selected_attack = "a"
		execute_attack()
	)
	attack_b_btn.pressed.connect(func():
		selected_attack = "b"
		execute_attack()
	)
	end_turn_btn.pressed.connect(end_turn)


func setup_hit_vignette():
	var vignette_gradient = Gradient.new()
	vignette_gradient.set_color(0, Color(1, 0, 0, 0))
	vignette_gradient.set_color(1, Color(0.365, 0.0, 0.0, 1.0))

	var grad_tex = GradientTexture2D.new()
	grad_tex.gradient = vignette_gradient
	grad_tex.fill = GradientTexture2D.FILL_RADIAL
	grad_tex.fill_from = Vector2(0.5, 0.5)
	grad_tex.fill_to = Vector2(1.0, 1.0)
	grad_tex.width = 512
	grad_tex.height = 512

	$HitVignette.texture = grad_tex
	$HitVignette.modulate.a = 0.0
	

func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			if not child.has_meta("skip_style"):
				child.mouse_entered.connect(SoundManager.play_hover)
				child.pressed.connect(SoundManager.play_click)
				SoundManager.style_button_paper(child)
		connect_button_sounds(child)

# ----------------------------
# FIGHT START
# ----------------------------
func start_fight():
	selected_hero_index = -1
	selected_attack = ""
	if RunData.fight_index % 5 != 0:
		enemy_max_hp = 10 + (RunData.fight_index * 5)
	else:
		enemy_max_hp = 10 + (RunData.fight_index * 10)
	enemy_hp = enemy_max_hp

	hand.clear()
	draw_to_hand(3)

	update_ui()


# ----------------------------
# DRAW SYSTEM
# ----------------------------
func draw_card():
	if deck.is_empty():
		deck = discard.duplicate()
		discard.clear()
		deck.shuffle()

	if deck.is_empty():
		return

	hand.append(deck.pop_back())


func draw_to_hand(target: int):
	while hand.size() < target:
		var before = hand.size()
		draw_card()
		if hand.size() == before:
			break


# ----------------------------
# HERO SELECTION
# ----------------------------
func select_hero(index: int):
	if index >= hand.size():
		return

	selected_hero_index = index
	info_label.text = "Selected: " + HeroDataBase.heroes[hand[index]]["display_name"]


# ----------------------------
# ATTACK SELECTION
# ----------------------------
func select_attack(type: String):
	selected_attack = type
	info_label.text = "Attack selected"


# ----------------------------
# ATTACK EXECUTION
# ----------------------------
func execute_attack():
	if not player_can_act:
		return

	if selected_hero_index == -1:
		return

	if selected_attack == "":
		return

	player_can_act = false

	var hero_id = hand[selected_hero_index]
	var hero = HeroDataBase.heroes[hero_id]

	var roll_result: Dictionary
	if selected_attack == "a":
		roll_result = roll_with_details(hero["attack_a"])
	else:
		roll_result = roll_with_details(hero["attack_b"])

	var base_damage = roll_result["total"]
	var rolls = roll_result["rolls"]

	var bonus = 0
	bonus += SaveManager.get_hero_attack_bonus(hero_id)
	if RunData.hero_upgrades.has(hero_id):
		bonus += RunData.hero_upgrades[hero_id].get("attack_bonus", 0)

	var dmg = base_damage + bonus

	await show_dice_animation(rolls, dmg, hero["display_name"] + "'s Attack!", Color(0.212, 0.544, 0.512, 1.0))

	enemy_hp -= dmg
	info_label.text = hero["display_name"] + " dealt " + str(dmg)

	# discard
	discard.append(hero_id)
	hand.remove_at(selected_hero_index)

	selected_hero_index = -1
	selected_attack = ""

	draw_to_hand(3)
	update_ui()

	# WIN CHECK
	if enemy_hp <= 0:
		var tokens_earned = calculate_token_reward()
		RunData.battles_won += 1
		RunData.fight_index += 1
		RunData.tokens += tokens_earned
		SaveManager.add_currency(tokens_earned)
		get_tree().change_scene_to_file("res://scenes/Upgrade.tscn")
		return

	# enemy turn
	player_can_act = false
	await get_tree().create_timer(0.6).timeout
	enemy_turn()
	
	
# run shit with scaling tokens fucking bitchass code fuck you
func calculate_token_reward() -> int:
	var fight_number = RunData.fight_index + 1

	if fight_number <= 10:
		return 1
	elif fight_number <= 25:
		return 2
	elif fight_number <= 50:
		return 3
	elif fight_number <= 100:
		return 4
	elif fight_number <= 200:
		return 5
	else:
		return 6
# ----------------------------
# WIN / LOSE
# ----------------------------
func win_fight():
	RunData.battles_won += 1
	RunData.fight_index += 1

	get_tree().change_scene_to_file("res://scenes/Upgrade.tscn")


func end_turn():
	var dmg = randi_range(2, 6)
	RunData.player_hp -= dmg
	flash_hit_vignette()   

# dying shit
	if RunData.player_hp <= 0:
		RunData.reset()
		get_tree().change_scene_to_file("res://scenes/Death.tscn")
		return

	update_ui()


# ----------------------------
# UTIL
# ----------------------------
func roll(arr: Array) -> int:
	var total := 0
	for x in arr:
		total += randi_range(1, x)
	return total


# ----------------------------
# UI UPDATE
# ----------------------------
func update_ui():
	hp_label.text = "HP: " + str(RunData.player_hp)
	fight_label.text = "Fight: " + str(RunData.fight_index)
	enemy_hp_label.text = "Enemy HP: " + str(enemy_hp)
	token_label.text = "Tokens: " + str(RunData.tokens)

	for i in hero_buttons.size():
		if i < hand.size():
			var id = hand[i]
			var hero = HeroDataBase.heroes[id]
			
			var stars = SaveManager.get_hero_star_level(id)
			var star_text = ""
			if stars > 0:
				star_text = "\n" + "★".repeat(stars)
			
			var run_bonus_text = ""
			if RunData.hero_upgrades.has(id):
				var run_bonus = RunData.hero_upgrades[id].get("attack_bonus", 0)
				if run_bonus > 0:
					run_bonus_text = "  +" + str(run_bonus)

			hero_buttons[i].text = hero["display_name"] + star_text + run_bonus_text
			hero_buttons[i].icon = hero.get("portrait")
			SoundManager.style_button_by_rarity(hero_buttons[i], hero["rarity"])
		else:
			hero_buttons[i].text = "-"
			hero_buttons[i].icon = null
			SoundManager.style_button_paper(hero_buttons[i])
func enemy_turn():
	var dmg = randi_range(2, 6)
	await show_dice_animation([dmg], dmg, "Enemy Attack!", Color(1.0, 0.35, 0.35))
	RunData.player_hp -= dmg
	flash_hit_vignette()
	info_label.text = "Enemy deals " + str(dmg)

	if RunData.player_hp <= 0:
		RunData.reset()
		get_tree().change_scene_to_file("res://scenes/Death.tscn")
		return

	start_player_turn()


func start_player_turn():
	player_can_act = true

	selected_hero_index = -1
	selected_attack = ""

	draw_to_hand(3)

	update_ui()
	
func flash_hit_vignette():
	var vignette = $HitVignette
	vignette.modulate.a = 0.7
	var tween = create_tween()
	tween.tween_property(vignette, "modulate:a", 0.0, 0.6)
	
	
	#roll animation shitting
	
	
func roll_with_details(arr: Array) -> Dictionary:
	var rolls: Array = []
	var total := 0
	for x in arr:
		var r = randi_range(1, x)
		rolls.append(r)
		total += r
	return {"rolls": rolls, "total": total}
	
	
func show_dice_animation(rolls: Array, total: int, title: String, accent_color: Color) -> void:
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.05, 0.85)
	style.set_border_width_all(3)
	style.border_color = accent_color
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	var title_label = Label.new()
	title_label.text = title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", accent_color)
	title_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(title_label)

	var dice_row = HBoxContainer.new()
	dice_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dice_row.add_theme_constant_override("separation", 10)
	vbox.add_child(dice_row)

	var die_labels = []
	for r in rolls:
		var die_label = Label.new()
		die_label.text = str(r)
		die_label.add_theme_font_size_override("font_size", 28)
		die_label.add_theme_color_override("font_color", Color.WHITE)
		die_label.scale = Vector2.ZERO
		dice_row.add_child(die_label)
		die_labels.append(die_label)

	var total_label = Label.new()
	total_label.text = "Total: " + str(total)
	total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_label.add_theme_font_size_override("font_size", 24)
	total_label.add_theme_color_override("font_color", accent_color)
	total_label.modulate.a = 0.0
	vbox.add_child(total_label)

	for die_label in die_labels:
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(die_label, "scale", Vector2.ONE, 0.25)
		SoundManager.play_click()
		await get_tree().create_timer(0.2).timeout

	var total_tween = create_tween()
	total_tween.tween_property(total_label, "modulate:a", 1.0, 0.2)
	await total_tween.finished

	await get_tree().create_timer(0.5).timeout

	var fade_tween = create_tween()
	fade_tween.tween_property(center, "modulate:a", 0.0, 0.3)
	await fade_tween.finished

	center.queue_free()
