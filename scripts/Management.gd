extends Control

const NAMES := [
	"GRAK", "VOSS", "ZARETH", "NAXIS", "KRUL", "THANE", "OREX", "VELD",
	"CRUX", "MORD", "SLASH", "BONE", "WREX", "DRAK", "TYKE", "SORN",
	"KAEL", "RAZE", "FLUX", "TOMB", "VEX", "GORN", "BLUD", "KRIX"
]

var _recruits: Array = []

func _ready() -> void:
	_recruits = _generate_recruits(4)
	$Layout/BottomBar/BtnDeploy.pressed.connect(_on_deploy)
	_refresh_credits()
	_refresh_roster()
	_refresh_recruits()
	_refresh_deploy()

func _generate_recruits(count: int) -> Array:
	var pool := NAMES.duplicate()
	pool.shuffle()
	var result := []
	for i in range(count):
		result.append({
			"name": pool[i],
			"cost": randi_range(150, 400),
			"strength": randi_range(1, 10),
			"speed": randi_range(1, 10),
			"armor": randi_range(1, 10),
		})
	return result

func _refresh_credits() -> void:
	$Layout/TopBar/LblCredits.text = "CREDITS: %d" % GameState.credits

func _refresh_deploy() -> void:
	$Layout/BottomBar/BtnDeploy.disabled = GameState.roster.is_empty()

func _refresh_roster() -> void:
	var list := $Layout/PanelsRow/RosterPanel/RosterList
	for child in list.get_children():
		child.queue_free()
	for gladiator in GameState.roster:
		list.add_child(_make_card(gladiator, true))

func _refresh_recruits() -> void:
	var list := $Layout/PanelsRow/RecruitsPanel/RecruitList
	for child in list.get_children():
		child.queue_free()
	for recruit in _recruits:
		list.add_child(_make_card(recruit, false))

func _make_card(data: Dictionary, is_roster: bool) -> PanelContainer:
	var card := PanelContainer.new()
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.05, 0.09, 1.0)
	bg.border_color = Color(1.0, 0.133, 0.267, 0.4)
	bg.set_border_width_all(1)
	bg.content_margin_left = 8
	bg.content_margin_right = 8
	bg.content_margin_top = 6
	bg.content_margin_bottom = 6
	card.add_theme_stylebox_override("panel", bg)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	# Name row
	var name_lbl := Label.new()
	name_lbl.text = data["name"]
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	name_lbl.add_theme_font_size_override("font_size", 16)
	vbox.add_child(name_lbl)

	# Cost
	var cost_lbl := Label.new()
	cost_lbl.text = "%d CR" % data["cost"]
	cost_lbl.add_theme_color_override("font_color", Color(1.0, 0.667, 0.0, 1.0))
	cost_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(cost_lbl)

	# Stats
	for stat in ["strength", "speed", "armor"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		vbox.add_child(row)

		var lbl := Label.new()
		lbl.text = stat.substr(0, 3).to_upper()
		lbl.custom_minimum_size = Vector2(36, 0)
		lbl.add_theme_color_override("font_color", Color(0.0, 1.0, 0.8, 1.0))
		lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(lbl)

		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 10
		bar.value = data[stat]
		bar.custom_minimum_size = Vector2(80, 14)
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.show_percentage = false
		row.add_child(bar)

	# Action button
	var btn := Button.new()
	if is_roster:
		btn.text = "FIRE"
		btn.pressed.connect(_on_fire.bind(data))
	else:
		btn.text = "HIRE"
		var can_hire := GameState.credits >= int(data["cost"]) and GameState.roster.size() < GameState.MAX_ROSTER_SIZE
		btn.disabled = not can_hire
		btn.pressed.connect(_on_hire.bind(data))

	var btn_normal := StyleBoxFlat.new()
	btn_normal.bg_color = Color(0.15, 0.02, 0.04, 1.0)
	btn_normal.border_color = Color(1.0, 0.133, 0.267, 1.0)
	btn_normal.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", btn_normal)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_font_size_override("font_size", 13)
	vbox.add_child(btn)

	return card

func _on_hire(data: Dictionary) -> void:
	if GameState.credits < data["cost"]:
		return
	if not GameState.add_gladiator(data):
		return
	GameState.credits -= data["cost"]
	_recruits.erase(data)
	GameState.save_game()
	_refresh_credits()
	_refresh_roster()
	_refresh_recruits()
	_refresh_deploy()

func _on_fire(data: Dictionary) -> void:
	GameState.remove_gladiator(data)
	GameState.credits += int(data["cost"] * 0.5)
	GameState.save_game()
	_refresh_credits()
	_refresh_roster()
	_refresh_recruits()
	_refresh_deploy()

func _on_deploy() -> void:
	var battle_path := "res://scenes/Battle.tscn"
	if not FileAccess.file_exists(battle_path):
		push_warning("Battle.tscn not found — deploy blocked")
		return
	get_tree().change_scene_to_file(battle_path)
