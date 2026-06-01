extends Control

const ENEMY_NAMES := [
	"GRAK", "VOSS", "ZARETH", "NAXIS", "KRUL", "THANE", "OREX", "VELD",
	"CRUX", "MORD", "SLASH", "BONE", "WREX", "DRAK", "TYKE", "SORN",
	"KAEL", "RAZE", "FLUX", "TOMB", "VEX", "GORN", "BLUD", "KRIX"
]

const SPONSOR_REWARD := 500
const DEFEAT_PENALTY := 200

const GRID_COLS := 5
const GRID_ROWS := 4
const UNIT_SIZE := Vector2(36, 36)

const COLOR_PLAYER := Color(0.0, 1.0, 0.8, 1.0)
const COLOR_ENEMY := Color(1.0, 0.133, 0.267, 1.0)
const COLOR_SELECTED_BORDER := Color(1, 1, 1, 1)

var _units: Array = []
var _initiative: Array = []
var _turn_index: int = 0
var _round: int = 1
var _battle_over: bool = false

@onready var _arena: Control = $Layout/MainRow/Arena
@onready var _player_list: VBoxContainer = $Layout/MainRow/PlayerHPPanel/PlayerList
@onready var _enemy_list: VBoxContainer = $Layout/MainRow/EnemyHPPanel/EnemyList
@onready var _lbl_round: Label = $Layout/TopBar/HBox/LblRound
@onready var _lbl_objective: Label = $Layout/TopBar/HBox/LblObjective
@onready var _lbl_turn: Label = $Layout/TopBar/HBox/LblTurn
@onready var _lbl_unit_info: Label = $Layout/BottomBar/HBox/LblUnitInfo
@onready var _btn_attack: Button = $Layout/BottomBar/HBox/BtnAttack
@onready var _btn_pass: Button = $Layout/BottomBar/HBox/BtnPass
@onready var _result_overlay: PanelContainer = $ResultOverlay
@onready var _lbl_result: Label = $ResultOverlay/VBox/LblResult
@onready var _lbl_reward: Label = $ResultOverlay/VBox/LblReward
@onready var _btn_continue: Button = $ResultOverlay/VBox/BtnContinue


func _ready() -> void:
	_apply_styles()
	_build_units()
	_sort_initiative()
	await get_tree().process_frame
	_place_units()
	_build_hp_bars()
	_btn_attack.pressed.connect(_on_attack)
	_btn_pass.pressed.connect(_on_pass)
	_btn_continue.pressed.connect(_on_continue)
	_lbl_objective.text = "ELIMINATE ALL ENEMIES"
	_start_turn()


func _apply_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.09, 1.0)
	panel_style.border_color = Color(1.0, 0.133, 0.267, 0.6)
	panel_style.set_border_width_all(1)

	for panel: PanelContainer in [$Layout/TopBar, $Layout/BottomBar,
			$Layout/MainRow/PlayerHPPanel, $Layout/MainRow/EnemyHPPanel]:
		panel.add_theme_stylebox_override("panel", panel_style.duplicate())

	var overlay_style := StyleBoxFlat.new()
	overlay_style.bg_color = Color(0.07, 0.05, 0.12, 0.95)
	overlay_style.border_color = Color(1.0, 0.133, 0.267, 1.0)
	overlay_style.set_border_width_all(2)
	$ResultOverlay.add_theme_stylebox_override("panel", overlay_style)

	for lbl: Label in [$Layout/TopBar/HBox/LblRound, $Layout/TopBar/HBox/LblTurn,
			$Layout/BottomBar/HBox/LblUnitInfo,
			$Layout/MainRow/PlayerHPPanel/PlayerList/LblPlayerTitle,
			$Layout/MainRow/EnemyHPPanel/EnemyList/LblEnemyTitle]:
		lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 1.0))
		lbl.add_theme_font_size_override("font_size", 14)

	$Layout/TopBar/HBox/LblObjective.add_theme_color_override("font_color", Color(1.0, 0.667, 0.0, 1.0))
	$Layout/TopBar/HBox/LblObjective.add_theme_font_size_override("font_size", 14)

	_style_button($Layout/BottomBar/HBox/BtnAttack)
	_style_button($Layout/BottomBar/HBox/BtnPass)
	_style_button($ResultOverlay/VBox/BtnContinue)

	$ResultOverlay/VBox/LblResult.add_theme_font_size_override("font_size", 40)
	$ResultOverlay/VBox/LblResult.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	$ResultOverlay/VBox/LblReward.add_theme_font_size_override("font_size", 20)
	$ResultOverlay/VBox/LblReward.add_theme_color_override("font_color", Color(1.0, 0.667, 0.0, 1.0))


func _style_button(btn: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.15, 0.02, 0.04, 1.0)
	normal.border_color = Color(1.0, 0.133, 0.267, 1.0)
	normal.set_border_width_all(2)
	btn.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.25, 0.04, 0.08, 1.0)
	hover.border_color = Color(1.0, 0.133, 0.267, 1.0)
	hover.set_border_width_all(2)
	btn.add_theme_stylebox_override("hover", hover)

	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_font_size_override("font_size", 14)


func _build_units() -> void:
	for i in range(GameState.roster.size()):
		var g: Dictionary = GameState.roster[i].duplicate()
		g["team"] = "player"
		g["grid_pos"] = Vector2i(i % 2, i)
		g["hp_max"] = 20 + g["armor"] * 2
		g["hp_current"] = g["hp_max"]
		g["rect_node"] = null
		g["hp_bar_node"] = null
		_units.append(g)

	var enemy_count: int = randi_range(3, 5)
	var name_pool: Array = ENEMY_NAMES.duplicate()
	name_pool.shuffle()
	for i in range(enemy_count):
		var e: Dictionary = {
			"name": name_pool[i],
			"strength": randi_range(1, 10),
			"speed": randi_range(1, 10),
			"armor": randi_range(1, 10),
			"team": "enemy",
			"grid_pos": Vector2i(3 + (i % 2), i),
			"hp_max": 0,
			"hp_current": 0,
			"rect_node": null,
			"hp_bar_node": null,
		}
		e["hp_max"] = 20 + int(e["armor"]) * 2
		e["hp_current"] = e["hp_max"]
		_units.append(e)


func _sort_initiative() -> void:
	_initiative = _units.duplicate()
	_initiative.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["speed"]) > int(b["speed"])
	)


func _iso_to_screen(grid_pos: Vector2i) -> Vector2:
	var arena_size: Vector2 = _arena.size
	var tile_w: float = arena_size.x / (GRID_COLS + 1.0)
	var tile_h: float = arena_size.y / (GRID_ROWS + 2.0)
	var cx: float = arena_size.x * 0.5
	var cy: float = arena_size.y * 0.35
	var x: float = cx + (grid_pos.x - grid_pos.y) * tile_w * 0.5
	var y: float = cy + (grid_pos.x + grid_pos.y) * tile_h * 0.4
	return Vector2(x - UNIT_SIZE.x * 0.5, y - UNIT_SIZE.y * 0.5)


func _place_units() -> void:
	for unit: Dictionary in _units:
		var rect := ColorRect.new()
		rect.custom_minimum_size = UNIT_SIZE
		rect.size = UNIT_SIZE
		rect.color = COLOR_PLAYER if unit["team"] == "player" else COLOR_ENEMY
		rect.position = _iso_to_screen(unit["grid_pos"])
		_arena.add_child(rect)
		unit["rect_node"] = rect


func _build_hp_bars() -> void:
	for unit: Dictionary in _units:
		var container := VBoxContainer.new()
		container.add_theme_constant_override("separation", 2)

		var name_lbl := Label.new()
		name_lbl.text = unit["name"]
		name_lbl.add_theme_font_size_override("font_size", 11)
		var name_color: Color = COLOR_PLAYER if unit["team"] == "player" else COLOR_ENEMY
		name_lbl.add_theme_color_override("font_color", name_color)
		container.add_child(name_lbl)

		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = unit["hp_max"]
		bar.value = unit["hp_current"]
		bar.custom_minimum_size = Vector2(130, 12)
		bar.show_percentage = false
		container.add_child(bar)

		unit["hp_bar_node"] = bar

		if unit["team"] == "player":
			_player_list.add_child(container)
		else:
			_enemy_list.add_child(container)


func _start_turn() -> void:
	if _battle_over or _initiative.is_empty():
		return

	var unit: Dictionary = _initiative[_turn_index]
	_lbl_round.text = "ROUND %d" % _round
	_lbl_turn.text = "TURN: %s" % unit["name"]
	_lbl_unit_info.text = "%s  STR:%d  SPD:%d  ARM:%d  HP:%d/%d" % [
		unit["name"], unit["strength"], unit["speed"],
		unit["armor"], unit["hp_current"], unit["hp_max"]
	]

	_highlight_active(unit)

	var is_player_turn: bool = unit["team"] == "player"
	_btn_attack.disabled = not is_player_turn
	_btn_pass.disabled = not is_player_turn

	if not is_player_turn:
		await get_tree().create_timer(0.6).timeout
		_enemy_act(unit)


func _highlight_active(active_unit: Dictionary) -> void:
	for unit: Dictionary in _initiative:
		if unit["rect_node"] == null:
			continue
		var rect: ColorRect = unit["rect_node"]
		if unit == active_unit:
			var style := StyleBoxFlat.new()
			var team_color: Color = COLOR_PLAYER if unit["team"] == "player" else COLOR_ENEMY
			style.bg_color = team_color
			style.border_color = COLOR_SELECTED_BORDER
			style.set_border_width_all(3)
			rect.color = team_color
		else:
			rect.color = COLOR_PLAYER if unit["team"] == "player" else COLOR_ENEMY


func _enemy_act(unit: Dictionary) -> void:
	var targets: Array = []
	for u: Dictionary in _units:
		if u["team"] == "player" and int(u["hp_current"]) > 0:
			targets.append(u)
	if targets.is_empty():
		_advance_turn()
		return
	var target: Dictionary = _find_nearest(unit, targets)
	_apply_attack(unit, target)


func _on_attack() -> void:
	if _battle_over or _initiative.is_empty():
		return
	var unit: Dictionary = _initiative[_turn_index]
	var targets: Array = []
	for u: Dictionary in _units:
		if u["team"] == "enemy" and int(u["hp_current"]) > 0:
			targets.append(u)
	if targets.is_empty():
		_advance_turn()
		return
	var target: Dictionary = _find_nearest(unit, targets)
	_apply_attack(unit, target)


func _on_pass() -> void:
	if _battle_over:
		return
	_advance_turn()


func _find_nearest(attacker: Dictionary, candidates: Array) -> Dictionary:
	var best: Dictionary = candidates[0]
	var best_dist: float = INF
	for c: Dictionary in candidates:
		var ap: Vector2i = attacker["grid_pos"]
		var cp: Vector2i = c["grid_pos"]
		var d: float = Vector2(float(ap.x), float(ap.y)).distance_to(Vector2(float(cp.x), float(cp.y)))
		if d < best_dist:
			best_dist = d
			best = c
	return best


func _apply_attack(attacker: Dictionary, target: Dictionary) -> void:
	var damage: int = maxi(1, int(attacker["strength"]) - int(target["armor"]))
	target["hp_current"] = maxi(0, int(target["hp_current"]) - damage)

	if target["hp_bar_node"] != null:
		(target["hp_bar_node"] as ProgressBar).value = target["hp_current"]

	_flash_hit(target)

	if int(target["hp_current"]) <= 0:
		await get_tree().create_timer(0.25).timeout
		_remove_dead(target)
		if _check_battle_end():
			return

	_advance_turn()


func _flash_hit(unit: Dictionary) -> void:
	if unit["rect_node"] == null:
		return
	var rect: ColorRect = unit["rect_node"]
	var original_color: Color = COLOR_PLAYER if unit["team"] == "player" else COLOR_ENEMY
	var tween := create_tween()
	tween.tween_property(rect, "color", Color(1, 1, 1, 1), 0.08)
	tween.tween_property(rect, "color", original_color, 0.12)


func _remove_dead(unit: Dictionary) -> void:
	if unit["rect_node"] != null:
		(unit["rect_node"] as ColorRect).queue_free()
		unit["rect_node"] = null
	if unit["hp_bar_node"] != null:
		(unit["hp_bar_node"] as ProgressBar).get_parent().queue_free()
		unit["hp_bar_node"] = null
	_units.erase(unit)
	_initiative.erase(unit)
	if _turn_index >= _initiative.size():
		_turn_index = 0


func _advance_turn() -> void:
	if _initiative.is_empty():
		return
	_turn_index = (_turn_index + 1) % _initiative.size()
	if _turn_index == 0:
		_round += 1
	_start_turn()


func _check_battle_end() -> bool:
	var players_alive: bool = false
	var enemies_alive: bool = false
	for u: Dictionary in _units:
		if u["team"] == "player":
			players_alive = true
		elif u["team"] == "enemy":
			enemies_alive = true
	if not enemies_alive:
		_show_result(true)
		return true
	if not players_alive:
		_show_result(false)
		return true
	return false


func _show_result(won: bool) -> void:
	_battle_over = true
	_btn_attack.disabled = true
	_btn_pass.disabled = true
	_result_overlay.visible = true

	if won:
		_lbl_result.text = "VICTORY"
		_lbl_result.add_theme_color_override("font_color", COLOR_PLAYER)
		GameState.credits += SPONSOR_REWARD
		_lbl_reward.text = "+%d CR" % SPONSOR_REWARD
	else:
		_lbl_result.text = "DEFEAT"
		_lbl_result.add_theme_color_override("font_color", COLOR_ENEMY)
		GameState.credits = maxi(0, GameState.credits - DEFEAT_PENALTY)
		_lbl_reward.text = "-%d CR" % DEFEAT_PENALTY


func _on_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/Management.tscn")
