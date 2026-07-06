extends Control

@onready var play_button = $PlayButton
@onready var store_button = $StoreButton
@onready var collection_button = $CollectionButton

func _ready():
	SaveManager.load_game()
	play_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
		
)
	store_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Store.tscn")
)
	collection_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Collection.tscn")
)
