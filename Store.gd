extends Control

@onready var return_button = $ReturnButton

func _ready():
	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://Title.tscn")
)
