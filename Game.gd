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

	deck = RunData.deck.duplicate()
	deck.shuffle()
	
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

	start_fight()


# ----------------------------
# FIGHT START
# ----------------------------
func start_fight():
	selected_hero_index = -1
	selected_attack = ""

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
		draw_card()


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

	var hero_id = hand[selected_hero_index]
	var hero = HeroDataBase.heroes[hero_id]

	var base_damage = 0

	if selected_attack == "a":
		base_damage = roll(hero["attack_a"])
	else:
		base_damage = roll(hero["attack_b"])

	var bonus = 0

	# Apply upgrade if it exists
	if RunData.hero_upgrades.has(hero_id):
		bonus = RunData.hero_upgrades[hero_id].get("attack_bonus", 0)

	var dmg = base_damage + bonus

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
		RunData.battles_won += 1
		RunData.fight_index += 1
		get_tree().change_scene_to_file("res://Upgrade.tscn")
		return

	# enemy turn
	player_can_act = false
	await get_tree().create_timer(0.3).timeout
	enemy_turn()

	# WIN CHECK (ONLY ONCE, CLEANLY)
	if enemy_hp <= 0:
		RunData.battles_won += 1
		RunData.fight_index += 1
		get_tree().change_scene_to_file("res://Upgrade.tscn")
	if enemy_hp > 0:
		enemy_turn()
	
	
# ----------------------------
# WIN / LOSE
# ----------------------------
func win_fight():
	RunData.battles_won += 1
	RunData.fight_index += 1

	get_tree().change_scene_to_file("res://Upgrade.tscn")


func end_turn():
	var dmg = randi_range(2, 6)
	RunData.player_hp -= dmg

# dying shit
	if RunData.player_hp <= 0:
		RunData.reset()
		get_tree().change_scene_to_file("res://Death.tscn")
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

	for i in hero_buttons.size():
		if i < hand.size():
			var id = hand[i]
			hero_buttons[i].text = HeroDataBase.heroes[id]["display_name"]
		else:
			hero_buttons[i].text = "-"
			
func enemy_turn():
	var dmg = randi_range(2, 6)
	RunData.player_hp -= dmg

	info_label.text = "Enemy deals " + str(dmg)

	if RunData.player_hp <= 0:
		RunData.reset()
		get_tree().change_scene_to_file("res://Death.tscn")
		return

	start_player_turn()


func start_player_turn():
	player_can_act = true

	selected_hero_index = -1
	selected_attack = ""

	draw_to_hand(3)

	update_ui()
	
