extends Control

@onready var grid = $ScrollContainer/HeroGrid
@onready var detail_panel = $DetailPanel
@onready var name_label = $DetailPanel/NameLabel
@onready var count_label = $DetailPanel/CountLabel
@onready var deck_button = $DetailPanel/DeckButton
@onready var return_button = $ReturnButton

var selected_hero = ""
var hero_counts = {}


func _ready():
	detail_panel.visible = false
	build_collection()

	deck_button.pressed.connect(_on_deck_button_pressed)

	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
	)


func build_collection():
	hero_counts.clear()

	# Count owned heroes (including duplicates)
	for hero_id in SaveManager.data["owned_heroes"]:
		if hero_counts.has(hero_id):
			hero_counts[hero_id] += 1
		else:
			hero_counts[hero_id] = 1

	# Clear grid
	for child in grid.get_children():
		child.queue_free()

	# Create cards
	for hero_id in hero_counts.keys():
		var card = create_card(hero_id)
		grid.add_child(card)


func create_card(hero_id):
	var btn = Button.new()

	var hero = HeroDataBase.heroes[hero_id]
	var count = hero_counts[hero_id]

	btn.text = hero["display_name"] + "\nx" + str(count)
	btn.custom_minimum_size = Vector2(140, 180)

	btn.pressed.connect(func():
		show_hero(hero_id)
	)

	return btn


func show_hero(hero_id):
	selected_hero = hero_id

	var hero = HeroDataBase.heroes[hero_id]

	detail_panel.visible = true
	name_label.text = hero["display_name"]
	count_label.text = "Owned: " + str(hero_counts[hero_id])

	update_deck_button(hero_id)


func update_deck_button(hero_id):
	if SaveManager.hero_in_deck(hero_id):
		deck_button.text = "Remove From Deck"
	else:
		deck_button.text = "Add To Deck"


func _on_deck_button_pressed():
	if selected_hero == "":
		return

	if SaveManager.hero_in_deck(selected_hero):
		SaveManager.remove_from_deck(selected_hero)
	else:
		if !SaveManager.add_to_deck(selected_hero):
			print("Deck is full!")
			return

	show_hero(selected_hero)
	build_collection()
