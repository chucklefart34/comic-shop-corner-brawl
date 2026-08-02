extends Control

@onready var return_button = $ReturnButton
@onready var buy_pack_button = $BuyPackButton
@onready var hero_name_label = $HeroNameLabel 
@onready var currency_label = $CurrencyLabel
@onready var rebirth_button = $RebirthButton
@onready var rebirth_confirm_dialog = $RebirthConfirmDialog
@onready var hero_portrait_rect = $HeroPortraitRect

func _ready():
	buy_pack_button.pressed.connect(_on_buy_pack_button_pressed)
	update_currency_label()
	hero_portrait_rect.visible = false
	rebirth_button.pressed.connect(_on_rebirth_button_pressed)           
	rebirth_confirm_dialog.confirmed.connect(_on_rebirth_confirmed) 
	$PackOpening.visible = false   

	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
	)
	connect_button_sounds(self)
	
func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(SoundManager.play_hover)
			child.pressed.connect(SoundManager.play_click)
			SoundManager.style_button_paper(child)  
		connect_button_sounds(child)
		
func update_currency_label():
	currency_label.text = "Tokens: " + str(SaveManager.data["currency"]) \
		+ "  (x" + str(SaveManager.data["token_multiplier"]) + " multiplier)"
	rebirth_button.disabled = not SaveManager.can_rebirth()
	
func _on_rebirth_button_pressed():
	if not SaveManager.can_rebirth():
		hero_name_label.text = "Need " + str(SaveManager.get_rebirth_threshold()) + " tokens to rebirth!"
		return
	rebirth_confirm_dialog.popup_centered()

func _on_rebirth_confirmed():
	SaveManager.do_rebirth()
	hero_name_label.text = "Rebirthed! Multiplier now x" + str(SaveManager.data["token_multiplier"])
	update_currency_label()

const ITEM_WIDTH = 140  # must match your slot's custom_minimum_size.x + HBox separation
const STRIP_LENGTH = 60
const WINNING_INDEX = 45

var _last_slot_crossed = -1
var _tick_start_x = 0.0

func _on_buy_pack_button_pressed():
	if not SaveManager.spend_currency(1):
		hero_name_label.text = "Not enough tokens!"
		hero_portrait_rect.visible = false
		return
	var result = open_booster()
	if result == null:
		return
	play_pack_animation(result)

func play_pack_animation(result: Dictionary):
	buy_pack_button.disabled = true
	hero_portrait_rect.visible = false
	hero_name_label.text = "Opening..."

	var item_strip = $PackOpening/ScrollClip/ItemStrip
	for c in item_strip.get_children():
		c.queue_free()

	for i in range(STRIP_LENGTH):
		var item_hero: Dictionary
		if i == WINNING_INDEX:
			item_hero = result["hero"]
		else:
			var filler_rarity = roll_rarity()
			var pool = []
			for hero_id in HeroDataBase.heroes:
				if HeroDataBase.heroes[hero_id]["rarity"] == filler_rarity:
					pool.append(hero_id)
			if pool.is_empty():
				pool = HeroDataBase.heroes.keys()
			item_hero = HeroDataBase.heroes[pool.pick_random()]
		item_strip.add_child(make_item_slot(item_hero))

	$PackOpening.visible = true
	item_strip.position.x = 0

	await get_tree().process_frame
	await get_tree().process_frame  

	var winning_slot = item_strip.get_child(WINNING_INDEX)
	var slot_center_x = winning_slot.position.x + winning_slot.size.x / 2.0
	var marker_x = $PackOpening/ScrollClip/Marker.position.x

	
	var jitter = randf_range(-winning_slot.size.x * 0.2, winning_slot.size.x * 0.2)
	var target_x = marker_x - slot_center_x + jitter

	# tick-sound tracking setup
	_last_slot_crossed = -1
	_tick_start_x = item_strip.position.x

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(_on_strip_scroll_tick, item_strip.position.x, target_x, 4.5)
	await tween.finished

	SoundManager.play_click()  # final landing "thunk"
	reveal_result(result)

func _on_strip_scroll_tick(current_x: float):
	var item_strip = $PackOpening/ScrollClip/ItemStrip
	item_strip.position.x = current_x

	var distance_scrolled = current_x - _tick_start_x
	var slots_passed = int(floor(abs(distance_scrolled) / ITEM_WIDTH))

	if slots_passed != _last_slot_crossed:
		_last_slot_crossed = slots_passed
		SoundManager.play_click()

func make_item_slot(hero: Dictionary) -> Control:
	var slot = PanelContainer.new()
	slot.custom_minimum_size = Vector2(120, 120)
	slot.size = Vector2(120, 120)        
	slot.clip_contents = true             

	var rarity_colors = {
		"Common": Color.WHITE,
		"Uncommon": Color.LIME_GREEN,
		"Rare": Color.DODGER_BLUE,
		"Epic": Color.MEDIUM_PURPLE,
		"Legendary": Color.GOLD
	}
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1)
	style.set_border_width_all(3)
	style.border_color = rarity_colors.get(hero["rarity"], Color.WHITE)
	slot.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	slot.add_child(margin)

	var tex_rect = TextureRect.new()
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL  
	tex_rect.custom_minimum_size = Vector2(104, 104)  
	if hero.get("portrait") != null:
		tex_rect.texture = hero["portrait"]
	margin.add_child(tex_rect)

	return slot
	
func reveal_result(result: Dictionary):
	var hero = result["hero"]
	var hero_id = result["id"]

	hero_name_label.text = "You got: " + hero["display_name"]
	if hero.get("portrait") != null:
		hero_portrait_rect.texture = hero["portrait"]
		hero_portrait_rect.visible = true

	SaveManager.add_hero(hero_id)
	update_currency_label()

	await get_tree().create_timer(1.2).timeout
	$PackOpening.visible = false
	buy_pack_button.disabled = false

func open_booster():
	var rarity = roll_rarity()

	var pool = []

	for hero_id in HeroDataBase.heroes:
		if HeroDataBase.heroes[hero_id]["rarity"] == rarity:
			pool.append(hero_id)

	if pool.is_empty():
		
		pool = HeroDataBase.heroes.keys()

	var hero_id = pool.pick_random()

	return {
		"id": hero_id,
		"hero": HeroDataBase.heroes[hero_id]
	}


func roll_rarity():
	var roll = randi_range(1, 100)

	if roll <= 60:
		return "Common"
	elif roll <= 85:
		return "Uncommon"
	elif roll <= 95:
		return "Rare"
	elif roll <= 99:
		return "Epic"
	else:
		return "Legendary"
