extends Control

const NEON_RED := Color(1.0, 0.133, 0.267, 1.0)
const NEON_RED_DIM := Color(1.0, 0.133, 0.267, 0.28)
const DARK_PANEL := Color(0.04, 0.04, 0.07, 0.88)

func _ready() -> void:
	$CenterLayout/BtnNewGame.pressed.connect(_on_new_game)
	$CenterLayout/BtnContinue.pressed.connect(_on_continue)
	$CenterLayout/BtnQuit.pressed.connect(_on_quit)
	$CenterLayout/BtnContinue.disabled = not GameState.has_save()
	_apply_bg_image()
	_apply_title_glow()
	_apply_button_styles()
	_apply_scanlines()


func _apply_bg_image() -> void:
	var tex := load("res://assets/sprites/menu_bg.png") as Texture2D
	if tex:
		$BgImage.texture = tex


func _apply_title_glow() -> void:
	# Absolute-positioned glow label on the root Control, placed to sit behind CenterLayout title
	var glow := Label.new()
	glow.text = "BLOODCORP"
	glow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glow.add_theme_font_size_override("font_size", UITheme.SIZE_DISPLAY + 10)
	glow.add_theme_color_override("font_color", NEON_RED_DIM)
	glow.set_anchors_preset(Control.PRESET_CENTER_TOP)
	glow.grow_horizontal = Control.GROW_DIRECTION_BOTH
	glow.offset_top = 142.0
	glow.offset_left = -300.0
	glow.offset_right = 300.0
	glow.offset_bottom = 220.0
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(glow)
	# Move behind CenterLayout but above Tint
	move_child(glow, get_child_count() - 2)


func _apply_button_styles() -> void:
	var buttons: Array = [
		$CenterLayout/BtnNewGame,
		$CenterLayout/BtnContinue,
		$CenterLayout/BtnQuit,
	]
	for btn: Button in buttons:
		# Normal — dark panel, thick left border as accent bar
		var normal := StyleBoxFlat.new()
		normal.bg_color = DARK_PANEL
		normal.border_color = NEON_RED
		normal.border_width_top = 1
		normal.border_width_right = 1
		normal.border_width_bottom = 1
		normal.border_width_left = 5
		normal.corner_radius_top_left = 2
		normal.corner_radius_bottom_left = 2
		normal.content_margin_left = 20.0
		btn.add_theme_stylebox_override("normal", normal)

		var hover := StyleBoxFlat.new()
		hover.bg_color = Color(0.18, 0.03, 0.06, 0.92)
		hover.border_color = NEON_RED
		hover.border_width_top = 1
		hover.border_width_right = 1
		hover.border_width_bottom = 1
		hover.border_width_left = 5
		hover.corner_radius_top_left = 2
		hover.corner_radius_bottom_left = 2
		hover.content_margin_left = 20.0
		btn.add_theme_stylebox_override("hover", hover)

		var pressed_style := StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.35, 0.05, 0.09, 0.95)
		pressed_style.border_color = NEON_RED
		pressed_style.border_width_top = 1
		pressed_style.border_width_right = 1
		pressed_style.border_width_bottom = 1
		pressed_style.border_width_left = 5
		pressed_style.corner_radius_top_left = 2
		pressed_style.corner_radius_bottom_left = 2
		pressed_style.content_margin_left = 20.0
		btn.add_theme_stylebox_override("pressed", pressed_style)

		var disabled_style := StyleBoxFlat.new()
		disabled_style.bg_color = Color(0.04, 0.04, 0.07, 0.6)
		disabled_style.border_color = Color(0.4, 0.1, 0.15, 0.5)
		disabled_style.border_width_top = 1
		disabled_style.border_width_right = 1
		disabled_style.border_width_bottom = 1
		disabled_style.border_width_left = 5
		disabled_style.content_margin_left = 20.0
		btn.add_theme_stylebox_override("disabled", disabled_style)

		btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.55, 1.0))
		btn.add_theme_font_size_override("font_size", UITheme.SIZE_BASE)

	$CenterLayout/Spacer.custom_minimum_size = Vector2(0, 52)


func _apply_scanlines() -> void:
	var shader := load("res://assets/shaders/scanlines.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		$Scanlines.material = mat


func _on_new_game() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Management.tscn")


func _on_continue() -> void:
	if GameState.load_game():
		get_tree().change_scene_to_file("res://scenes/Management.tscn")


func _on_quit() -> void:
	get_tree().quit()
