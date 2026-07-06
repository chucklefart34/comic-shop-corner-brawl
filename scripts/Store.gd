extends Control

@onready var return_button = $ReturnButton
@onready var buy_pack_button = $BuyPackButton


func _ready():
	buy_pack_button.pressed.connect(_on_buy_pack_button_pressed)

	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
	)


func _on_buy_pack_button_pressed():
	var result = open_booster()

	if result == null:
		return

	var hero = result["hero"]
	var hero_id = result["id"]

	print("You got: ", hero["display_name"])

	SaveManager.add_hero(hero_id)

# -------------------------
# PACK SYSTEM
# -------------------------

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
