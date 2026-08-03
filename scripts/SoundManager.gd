extends Node

@onready var hover_player = AudioStreamPlayer.new()
@onready var click_player = AudioStreamPlayer.new()

var hover_sound = preload("res://sounds/hover.ogg")
var click_sound = preload("res://sounds/click.ogg")

var paper_white_texture = preload("res://picstures/white.png")
var paper_grey_texture = preload("res://picstures/grey.png")
var main_font = preload("res://fonts/Schoolbell-Regular.ttf")  

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
	button.add_theme_stylebox_override("disabled", grey_style)
	button.add_theme_font_override("font", main_font)
		
	button.add_theme_color_override("font_color", Color.BLACK)
	button.add_theme_color_override("font_hover_color", Color.BLACK)
	button.add_theme_color_override("font_pressed_color", Color.BLACK)
	button.add_theme_color_override("font_disabled_color", Color(0, 0, 0, 0.4))


func connect_and_style_button(button: Button):
	button.mouse_entered.connect(play_hover)
	button.pressed.connect(play_click)
	style_button_paper(button)


var rarity_colors = {
	"Common": Color.WHITE,
	"Uncommon": Color.LIME_GREEN,
	"Rare": Color.DODGER_BLUE,
	"Epic": Color.MEDIUM_PURPLE,
	"Legendary": Color.GOLD
}


func get_rarity_color(rarity: String) -> Color:
	return rarity_colors.get(rarity, Color.WHITE)


func style_card_by_rarity(panel: PanelContainer, rarity: String):
	var rarity_color = get_rarity_color(rarity)

	var style = StyleBoxFlat.new()
	style.bg_color = rarity_color.darkened(0.75)  # dimmed so text/portrait stays readable
	style.set_border_width_all(3)
	style.border_color = rarity_color

	panel.add_theme_stylebox_override("panel", style)

func style_button_by_rarity(button: Button, rarity: String):
	var rarity_color = get_rarity_color(rarity)

	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = rarity_color.darkened(0.75)
	normal_style.set_border_width_all(3)
	normal_style.border_color = rarity_color
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.corner_radius_bottom_right = 8

	var hover_style = normal_style.duplicate()
	hover_style.bg_color = rarity_color.darkened(0.6)

	var pressed_style = normal_style.duplicate()
	pressed_style.bg_color = rarity_color.darkened(0.85)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", normal_style)
	button.add_theme_stylebox_override("disabled", hover_style)
	button.add_theme_font_override("font", main_font)
		
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
