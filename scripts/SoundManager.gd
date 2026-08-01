extends Node

@onready var hover_player = AudioStreamPlayer.new()
@onready var click_player = AudioStreamPlayer.new()

var hover_sound = preload("res://Sounds/hover.ogg")
var click_sound = preload("res://Sounds/click.ogg")

func _ready():
	add_child(hover_player)
	add_child(click_player)
	hover_player.stream = hover_sound
	click_player.stream = click_sound

func play_hover():
	hover_player.stop()
	hover_player.play()

func play_click():
	click_player.stop()
	click_player.play()
