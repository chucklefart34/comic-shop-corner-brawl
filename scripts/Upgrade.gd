extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var option1 = $VBoxContainer/Option1
@onready var option2 = $VBoxContainer/Option2
@onready var option3 = $VBoxContainer/Option3
@onready var info_label = $VBoxContainer/InfoLabel

var upgrades = []

# ----------------------------
# INIT
# ----------------------------
func _ready():
	randomize()

	upgrades = [
		{"name":"Heal 5 HP", "type":"heal"},
		{"name":"+1 Damage (Hero1)", "type":"buff_hero1"},
		{"name":"Remove Random Card", "type":"remove_card"},
		{"name":"Increase Max HP +5", "type":"max_hp"},
		{"name":"Add Hero1 to deck", "type":"add_card"}
	]

	upgrades.shuffle()

	option1.text = upgrades[0]["name"]
	option2.text = upgrades[1]["name"]
	option3.text = upgrades[2]["name"]

	option1.pressed.connect(func(): pick_upgrade(0))
	option2.pressed.connect(func(): pick_upgrade(1))
	option3.pressed.connect(func(): pick_upgrade(2))


# ----------------------------
# PICK UPGRADE
# ----------------------------
func pick_upgrade(index: int):
	var upg = upgrades[index]

	match upg["type"]:

		"heal":
			RunData.player_hp = min(RunData.player_hp + 5, RunData.player_max_hp)

		"max_hp":
			RunData.player_max_hp += 5
			RunData.player_hp += 5

		"attack_bonus_hero1":
			if not RunData.hero_upgrades.has("Hero1"):
				RunData.hero_upgrades["Hero1"] = {}

			RunData.hero_upgrades["Hero1"]["attack_bonus"] = \
				RunData.hero_upgrades["Hero1"].get("attack_bonus", 0) + 1
	info_label.text = "Upgrade applied!"

	await get_tree().create_timer(0.8).timeout

	get_tree().change_scene_to_file("res://scenes/Game.tscn")
