extends Control

@onready var stats_label = $StatsLabel
@onready var return_button = $ReturnButton
@onready var run_stats_label = $RunStatsLabel

func _ready():
	stats_label.text = "Total Battles Won: " + str(RunData.battles_won)
	run_stats_label.text = "Battles won this round: " + str(RunData.fight_index)

	
	

	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Title.tscn")
		RunData.reset()
)

	connect_button_sounds(self)

func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(SoundManager.play_hover)
			child.pressed.connect(SoundManager.play_click)
		connect_button_sounds(child)  # recurse into children too
		
