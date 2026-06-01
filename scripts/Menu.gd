extends Control

func _ready() -> void:
	$CenterLayout/BtnNewGame.pressed.connect(_on_new_game)
	$CenterLayout/BtnContinue.pressed.connect(_on_continue)
	$CenterLayout/BtnQuit.pressed.connect(_on_quit)
	$CenterLayout/BtnContinue.disabled = not GameState.has_save()
	_apply_button_styles()
	_apply_scanlines()

func _apply_scanlines() -> void:
	var shader := load("res://assets/shaders/scanlines.gdshader") as Shader
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		$Scanlines.material = mat

func _apply_button_styles() -> void:
	var buttons := [$CenterLayout/BtnNewGame, $CenterLayout/BtnContinue, $CenterLayout/BtnQuit]
	for btn in buttons:
		var normal := StyleBoxFlat.new()
		normal.bg_color = Color(0.05, 0.05, 0.08, 1.0)
		normal.border_color = Color(1.0, 0.133, 0.267, 1.0)
		normal.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", normal)

		var hover := StyleBoxFlat.new()
		hover.bg_color = Color(0.2, 0.03, 0.06, 1.0)
		hover.border_color = Color(1.0, 0.133, 0.267, 1.0)
		hover.set_border_width_all(2)
		btn.add_theme_stylebox_override("hover", hover)

		var pressed_style := StyleBoxFlat.new()
		pressed_style.bg_color = Color(0.4, 0.05, 0.1, 1.0)
		pressed_style.border_color = Color(1.0, 0.133, 0.267, 1.0)
		pressed_style.set_border_width_all(2)
		btn.add_theme_stylebox_override("pressed", pressed_style)

func _on_new_game() -> void:
	GameState.reset()
	get_tree().change_scene_to_file("res://scenes/Management.tscn")

func _on_continue() -> void:
	if GameState.load_game():
		get_tree().change_scene_to_file("res://scenes/Management.tscn")

func _on_quit() -> void:
	get_tree().quit()
