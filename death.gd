extends Control

@onready var stats_label = $StatsLabel
@onready var return_button = $ReturnButton

func _ready():
	stats_label.text = "Battles Won: " + str(RunData.battles_won)

	return_button.pressed.connect(func():
		RunData.reset()
		get_tree().change_scene_to_file("res://Title.tscn")
)
