extends Control

@onready var play_button = $PlayButton
@onready var store_button = $StoreButton
@onready var collection_button = $CollectionButton
@onready var help_button = $HelpButton
@onready var help_panel = $HelpPanel
@onready var help_text = $HelpPanel/HelpText
@onready var close_help_button = $HelpPanel/CloseHelpButton
@onready var multi_button = $HelpPanel/MultiButton

func _ready():
	SaveManager.load_game()
	play_button.pressed.connect(func():
		RunData.start_new_run()
		get_tree().change_scene_to_file("res://scenes/Game.tscn")
		
	
)
	store_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Store.tscn")
)
	collection_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Collection.tscn")
)
	help_panel.visible = false
	help_button.pressed.connect(_on_help_button_pressed)
	close_help_button.pressed.connect(_on_close_help_button_pressed)


	multi_button.pressed.connect(func():
		SaveManager.multiply_currency(10)
		
		
	)
	connect_button_sounds(self)

func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			child.mouse_entered.connect(SoundManager.play_hover)
			child.pressed.connect(SoundManager.play_click)
			SoundManager.style_button_paper(child)  
		connect_button_sounds(child)
		
	help_text.text = "HOW TO PLAY\n\n" + \
		"Build a deck of heroes in your Collection.\n" + \
		"Each fight, draw 3 heroes into your hand.\n" + \
		"Select a hero, then choose an attack.\n" + \
		"Attack A(Low Risk) or Attack B(High Risk)\n" + \
		"Defeat the enemy before your HP runs out.\n" + \
		"Win fights to earn upgrades and tokens.\n" + \
		"Collect duplicate heroes to earn stars\n" + \
		"and permanent attack bonuses\n" + \
		"Instagram: chucklefart34 adarexists"
		
	
func _on_help_button_pressed():
	help_panel.visible = true

func _on_close_help_button_pressed():
	help_panel.visible = false
