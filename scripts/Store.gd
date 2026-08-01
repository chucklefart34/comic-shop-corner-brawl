extends Control

@onready var return_button = $ReturnButton
@onready var buy_pack_button = $BuyPackButton
@onready var hero_name_label = $HeroNameLabel 
@onready var currency_label = $CurrencyLabel
@onready var rebirth_button = $RebirthButton
@onready var rebirth_confirm_dialog = $RebirthConfirmDialog

func _ready():
	buy_pack_button.pressed.connect(_on_buy_pack_button_pressed)
	rebirth_button.pressed.connect(_on_rebirth_button_pressed)
	update_currency_label()
	rebirth_confirm_dialog.confirmed.connect(_on_rebirth_confirmed)
	update_currency_label()
	
	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
		update_currency_label()
	)
	connect_button_sounds(self)

func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(SoundManager.play_hover)
			child.pressed.connect(SoundManager.play_click)
		connect_button_sounds(child)  # recurse into children too
	
func update_currency_label():
	currency_label.text = "Tokens: " + str(SaveManager.data["currency"]) \
		+ "  (x" + str(SaveManager.data["token_multiplier"]) + " multiplier)"
	rebirth_button.disabled = not SaveManager.can_rebirth()
	
func _on_rebirth_button_pressed():
	if not SaveManager.can_rebirth():
		hero_name_label.text = "Need " + str(SaveManager.REBIRTH_THRESHOLD) + " tokens to rebirth!"
		return
	rebirth_confirm_dialog.popup_centered()

func _on_rebirth_confirmed():
	SaveManager.do_rebirth()
	hero_name_label.text = "Rebirthed! Multiplier now x" + str(SaveManager.data["token_multiplier"])
	update_currency_label()

func _on_buy_pack_button_pressed():
	if not SaveManager.spend_currency(1):
		hero_name_label.text = ("Not enough tokens!")
		return
	var result = open_booster()

	if result == null:
		return

	var hero = result["hero"]
	var hero_id = result["id"]

	print("You got: ", hero["display_name"])
	hero_name_label.text = "You got: " + hero["display_name"]
	SaveManager.add_hero(hero_id)
	update_currency_label()

	

func open_booster():
	var rarity = roll_rarity()

	var pool = []

	for hero_id in HeroDataBase.heroes:
		if HeroDataBase.heroes[hero_id]["rarity"] == rarity:
			pool.append(hero_id)

	if pool.is_empty():
		# fallback so game NEVER breaks
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
