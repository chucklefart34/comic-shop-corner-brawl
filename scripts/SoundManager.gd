extends Node

@onready var hover_player = AudioStreamPlayer.new()
@onready var click_player = AudioStreamPlayer.new()

var hover_sound = preload("res://Sounds/hover.ogg")
var click_sound = preload("res://Sounds/click.ogg")

var paper_white_texture = preload("res://picstures/white.png")
var paper_grey_texture = preload("res://picstures/grey.png")


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


func style_button_paper(button: Button):
	var white_style = StyleBoxTexture.new()
	white_style.texture = paper_white_texture

	var grey_style = StyleBoxTexture.new()
	grey_style.texture = paper_grey_texture

	button.add_theme_stylebox_override("normal", white_style)
	button.add_theme_stylebox_override("hover", grey_style)
	button.add_theme_stylebox_override("pressed", grey_style)
	button.add_theme_stylebox_override("focus", white_style)  # avoid default blue focus outline
	button.add_theme_stylebox_override("disabled", white_style)

	button.add_theme_color_override("font_color", Color.BLACK)
	button.add_theme_color_override("font_hover_color", Color.BLACK)
	button.add_theme_color_override("font_pressed_color", Color.BLACK)
	button.add_theme_color_override("font_disabled_color", Color(0, 0, 0, 0.4))


func connect_and_style_button(button: Button):
	button.mouse_entered.connect(play_hover)
	button.pressed.connect(play_click)
	style_button_paper(button)
