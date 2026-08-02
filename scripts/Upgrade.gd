extends Control
@onready var title_label = $VBoxContainer/TitleLabel
@onready var option1 = $VBoxContainer/Option1
@onready var option2 = $VBoxContainer/Option2
@onready var option3 = $VBoxContainer/Option3
@onready var info_label = $VBoxContainer/InfoLabel
var upgrades = []
# INIT
func _ready():
	randomize()
	upgrades = [
		{"name":"Heal 10 HP", "type":"heal"},
		{"name":"+1 Damage (Random Hero)", "type":"buff_random"},
		{"name":"Remove Random Card", "type":"remove_card"},
		{"name":"Increase Max HP +5", "type":"max_hp"},
		{"name":"Add Random Card", "type":"add_card"}
	]
	upgrades.shuffle()
	option1.text = upgrades[0]["name"]
	option2.text = upgrades[1]["name"]
	option3.text = upgrades[2]["name"]
	option1.pressed.connect(func(): pick_upgrade(0))
	option2.pressed.connect(func(): pick_upgrade(1))
	option3.pressed.connect(func(): pick_upgrade(2))
	
	connect_button_sounds(self)  

# PICK UPGRADE
func pick_upgrade(index: int):
	option1.disabled = true
	option2.disabled = true
	option3.disabled = true

	var upg = upgrades[index]
	match upg["type"]:
		"heal":
			RunData.player_hp = min(RunData.player_hp + 10, RunData.player_max_hp)
		"max_hp":
			RunData.player_max_hp += 5
			RunData.player_hp += 5
		"buff_random":
			if RunData.deck.size() > 0:
				var idx = randi() % RunData.deck.size()
				var hero_id = RunData.deck[idx]
				if not RunData.hero_upgrades.has(hero_id):
					RunData.hero_upgrades[hero_id] = {}
				RunData.hero_upgrades[hero_id]["attack_bonus"] = \
					RunData.hero_upgrades[hero_id].get("attack_bonus", 0) + 1
					
		"remove_card":
			if RunData.deck.size() > 0:
				var idx = randi() % RunData.deck.size()
				RunData.deck.remove_at(idx)
		"add_card":
			if RunData.deck.size() <= 9 and RunData.deck.size() > 0:
				var idx = randi() % RunData.deck.size()
				var hero_id = RunData.deck[idx]
				RunData.deck.append(hero_id)
	info_label.text = "Upgrade applied!"
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

	

func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			if not child.has_meta("skip_style"):
				child.mouse_entered.connect(SoundManager.play_hover)
				child.pressed.connect(SoundManager.play_click)
				SoundManager.style_button_paper(child)
		connect_button_sounds(child)
		
