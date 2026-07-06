extends Control

@onready var play_button = $PlayButton

func _ready():
	play_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://Game.tscn")
)
