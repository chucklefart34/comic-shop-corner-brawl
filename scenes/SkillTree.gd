extends Control

const BRANCH_INFO = {
	"attack": {"label": "Attack", "color": Color(1, 0.4, 0.4), "angle": -90},
	"hp": {"label": "Vitality", "color": Color(0.4, 1, 0.4), "angle": 0},
	"tokens": {"label": "Wealth", "color": Color(1, 0.85, 0.3), "angle": 90},
	"luck": {"label": "Luck", "color": Color(0.6, 0.4, 1), "angle": 180}
}

const TIERS = 5
const NODE_RADIUS = 30
const TIER_SPACING = 90
const BRANCH_DESCRIPTIONS = {
	"attack": "+1 flat damage per attack",
	"hp": "+5 max HP",
	"tokens": "+10% tokens earned",
	"luck": "+3% better pack odds"
}

@onready var token_label = $TokenLabel
@onready var return_button = $ReturnButton
@onready var content_layer = $ContentLayer
@onready var lines_layer = $ContentLayer/LinesLayer
@onready var nodes_layer = $ContentLayer/NodesLayer
@onready var info_label = $InfoLabel

var dragging = false
var drag_start_mouse: Vector2
var drag_start_content_pos: Vector2
var center: Vector2

func _ready():
	center = get_viewport_rect().size / 2
	return_button.pressed.connect(func():
		get_tree().change_scene_to_file("res://scenes/Store.tscn")
	
	)
	connect_button_sounds(self)
	build_tree()
	update_token_label()
	
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start_mouse = event.position
			drag_start_content_pos = content_layer.position
		else:
			dragging = false

	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - drag_start_mouse
		content_layer.position = drag_start_content_pos + delta

	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging = true
			drag_start_mouse = event.position
			drag_start_content_pos = content_layer.position
		else:
			dragging = false

	elif event is InputEventScreenDrag:
		var delta = event.position - drag_start_mouse
		content_layer.position = drag_start_content_pos + delta
		
func connect_button_sounds(node: Node):
	for child in node.get_children():
		if child is Button:
			if not child.has_meta("skip_style"):
				child.mouse_entered.connect(SoundManager.play_hover)
				child.pressed.connect(SoundManager.play_click)
				SoundManager.style_button_paper(child)
		connect_button_sounds(child)

func update_token_label():
	token_label.text = "Skill Points: " + str(SaveManager.get_skill_points())
	

func build_tree():
	for child in lines_layer.get_children():
		child.queue_free()
	for child in nodes_layer.get_children():
		child.queue_free()

	var hub = make_node_button("★", center, Color.WHITE, -1, "")
	hub.disabled = true
	hub.set_meta("skip_style", true)
	nodes_layer.add_child(hub)

	for branch in BRANCH_INFO.keys():
		var info = BRANCH_INFO[branch]
		var angle_rad = deg_to_rad(info["angle"])
		var dir = Vector2(cos(angle_rad), sin(angle_rad))
		var prev_pos = center
		var level = SaveManager.get_skill_level(branch)

		for tier in range(TIERS):
			var pos = center + dir * TIER_SPACING * (tier + 1)

			var line = Line2D.new()
			line.width = 4
			line.points = [prev_pos, pos]
			line.default_color = info["color"] if tier < level else Color(0.3, 0.3, 0.3)
			lines_layer.add_child(line)

			var btn = make_node_button(str(tier + 1), pos, info["color"], tier, branch)
			nodes_layer.add_child(btn)

			prev_pos = pos

func make_node_button(label_text: String, pos: Vector2, color: Color, tier: int, branch: String) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(NODE_RADIUS * 2, NODE_RADIUS * 2)
	btn.position = pos - Vector2(NODE_RADIUS, NODE_RADIUS)
	btn.text = label_text
	btn.set_meta("skip_style", true)

	var level = 0
	if branch != "":
		level = SaveManager.get_skill_level(branch)

	var owned = tier < level
	var buyable = tier == level

	var style = StyleBoxFlat.new()
	style.set_corner_radius_all(NODE_RADIUS)
	style.set_border_width_all(3)

	if owned:
		style.bg_color = color.darkened(0.3)
		style.border_color = color
	elif buyable:
		style.bg_color = Color(0.15, 0.15, 0.15)
		style.border_color = color
	else:
		style.bg_color = Color(0.08, 0.08, 0.08)
		style.border_color = Color(0.25, 0.25, 0.25)

	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("disabled", style)
	btn.add_theme_color_override("font_color", Color.WHITE if (owned or buyable) else Color(0.4, 0.4, 0.4))

	if branch != "":
		btn.pressed.connect(func(): show_node_info(branch, tier))
		btn.mouse_entered.connect(func(): SoundManager.play_hover())

	return btn

func show_node_info(branch: String, tier: int):
	var info = BRANCH_INFO[branch]
	var level = SaveManager.get_skill_level(branch)
	var desc = BRANCH_DESCRIPTIONS[branch]

	if tier < level:
		info_label.text = info["label"] + " Tier " + str(tier + 1) + " — Owned (" + desc + ")"
	elif tier == level:
		info_label.text = info["label"] + " Tier " + str(tier + 1) + " — " + desc + "  [Tap again to unlock]"
		try_buy(branch, tier)
	else:
		info_label.text = info["label"] + " Tier " + str(tier + 1) + " — Locked (" + desc + "). Unlock Tier " + str(level + 1) + " first."

func try_buy(branch: String, _tier: int):
	if SaveManager.buy_skill(branch):
		build_tree()
		update_token_label()
