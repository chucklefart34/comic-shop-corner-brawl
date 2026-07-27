extends Control

@onready var grid = $ScrollContainer/HeroGrid
@onready var detail_panel = $DetailPanel
@onready var name_label = $DetailPanel/NameLabel
@onready var count_label = $DetailPanel/CountLabel
@onready var deck_button = $DetailPanel/DeckButton
@onready var return_button = $ReturnButton
@onready var back_button = $DetailPanel/BackButton
@onready var announce_label = $DetailPanel/AnnounceLabel 
@onready var view_deck_button = $ViewDeckButton
@onready var deck_panel = $DeckPanel
@onready var deck_grid = $DeckPanel/ScrollContainer/DeckGrid
@onready var close_deck_button = $DeckPanel/CloseDeckButton

var selected_hero = ""
var hero_counts = {}


func _ready():
	detail_panel.visible = false
	deck_panel.visible = false
	build_collection()
	deck_button.pressed.connect(_on_deck_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	view_deck_button.pressed.connect(_on_view_deck_button_pressed)
	close_deck_button.pressed.connect(_on_close_deck_button_pressed)
	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
	)
	
	connect_button_sounds(self)

func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(SoundManager.play_hover)
			child.pressed.connect(SoundManager.play_click)
		connect_button_sounds(child)  # recurse into children too
	

func _on_view_deck_button_pressed():
	build_deck_panel()
	deck_panel.visible = true

func _on_close_deck_button_pressed():
	deck_panel.visible = false

func build_deck_panel():
	for child in deck_grid.get_children():
		child.queue_free()
	for hero_id in SaveManager.data["deck"]:
		var card = create_deck_card(hero_id)
		deck_grid.add_child(card)

func create_deck_card(hero_id):
	var container = VBoxContainer.new()
	var hero = HeroDataBase.heroes[hero_id]

	var portrait = TextureRect.new()
	portrait.texture = hero["portrait"]
	portrait.custom_minimum_size = Vector2(140, 140)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var label = Label.new()
	label.text = hero["display_name"]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	container.add_child(portrait)
	container.add_child(label)
	return container

func _on_back_button_pressed():
	detail_panel.visible = false
	selected_hero = ""

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
	btn.custom_minimum_size = Vector2(140, 180)

	var stars = SaveManager.get_hero_star_level(hero_id)
	var star_text = ""
	if stars > 0:
		star_text = "\n" + "★".repeat(stars)

	var vbox = VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var portrait_node
	if hero.get("portrait") != null:
		portrait_node = TextureRect.new()
		portrait_node.texture = hero["portrait"]
		portrait_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	else:
		portrait_node = ColorRect.new()
		portrait_node.color = hero.get("color", Color(0.5, 0.5, 0.5))
	portrait_node.custom_minimum_size = Vector2(140, 140)
	portrait_node.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label = Label.new()
	label.text = hero["display_name"] + "\nx" + str(count) + star_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	vbox.add_child(portrait_node)
	vbox.add_child(label)
	btn.add_child(vbox)

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

	var stars = SaveManager.get_hero_star_level(hero_id)
	if stars > 0:
		count_label.text += "  |  " + "★".repeat(stars) + "  (+" + str(stars * SaveManager.ATTACK_BONUS_PER_STAR) + " ATK)"

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
			announce_label.text = ("Deck is full!")
			return
	

	show_hero(selected_hero)
	build_collection()
	
	
