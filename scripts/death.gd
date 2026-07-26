extends Control

@onready var stats_label = $StatsLabel
@onready var return_button = $ReturnButton
@onready var run_stats_label = $RunStatsLabel

func _ready():
	stats_label.text = "Total Battles Won: " + str(RunData.battles_won)
	run_stats_label.text = "Battles won this round: " + str(RunData.fight_index)
	
	return_button.pressed.connect(func():
		RunData.reset()
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
)
