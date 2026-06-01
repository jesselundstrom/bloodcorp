extends Control

const ENEMY_NAMES := [
	"GRAK", "VOSS", "ZARETH", "NAXIS", "KRUL", "THANE", "OREX", "VELD",
	"CRUX", "MORD", "SLASH", "BONE", "WREX", "DRAK", "TYKE", "SORN",
	"KAEL", "RAZE", "FLUX", "TOMB", "VEX", "GORN", "BLUD", "KRIX"
]

# Sponsor data is read from GameState.active_sponsor at _ready.

const GRID_COLS := 7
const GRID_ROWS := 5
const UNIT_SIZE := Vector2(56, 56)
const MOVE_TILE_SIZE := Vector2(42, 28)
const DEFAULT_MOVE_RANGE := 2
const DEFAULT_ATTACK_RANGE := 1

# Sprite sheet: 1536x1024, 3 columns x 2 rows of 512x512 frames
const SPRITE_SHEET_PATH := "res://assets/sprites/gladiators.png"
const SPRITE_FRAME_W := 512
const SPRITE_FRAME_H := 512
const SPRITE_COLS := 3
const SPRITE_ROWS := 2

const COLOR_PLAYER := Color(0.0, 1.0, 0.8, 1.0)
const COLOR_ENEMY := Color(1.0, 0.133, 0.267, 1.0)
const COLOR_SELECTED_BORDER := Color(1, 1, 1, 1)
const COLOR_ACTIVE_BORDER := Color(0.0, 1.0, 0.8, 0.85)
const COLOR_HOVER_BORDER := Color(1, 1, 1, 0.45)
const COLOR_ATTACK_READY := Color(1.0, 0.133, 0.267, 1.0)
const COLOR_ATTACK_DISABLED := Color(0.22, 0.22, 0.25, 1.0)
const COLOR_MOVE_TILE := Color(0.0, 1.0, 0.8, 0.28)
const COLOR_MOVE_TILE_HOVER := Color(0.0, 1.0, 0.8, 0.52)
const COLOR_TRANSPARENT := Color(0, 0, 0, 0)
const COLOR_OBSTACLE := Color(0.12, 0.09, 0.07, 0.92)
const COLOR_OBSTACLE_BORDER := Color(0.55, 0.38, 0.0, 0.85)
const COLOR_CHARGE := Color(1.0, 0.55, 0.0, 1.0)
const COLOR_MARK := Color(0.8, 0.0, 1.0, 1.0)
const MARK_BONUS := 2
const FLANK_BONUS := 3

# Midfield cols 2-4 only; avoids player deployment (cols 0-1) and enemy (cols 5-6)
const OBSTACLE_POSITIONS: Array = [
	Vector2i(2, 1), Vector2i(4, 1), Vector2i(3, 2), Vector2i(2, 3), Vector2i(4, 3)
]

var _units: Array = []
var _initiative: Array = []
var _turn_index: int = 0
var _round: int = 1
var _battle_over: bool = false
var _selected_target = null
var _hovered_target = null
var _move_tiles: Array = []
var _attack_range_tiles: Array = []
var _sprite_sheet: Texture2D = null
var _combat_log: RichTextLabel = null
var _kills: int = 0
var _mark_killed: bool = false
var _sponsor: Dictionary = {}
var _marked_unit = null
var _style_score: int = 0

@onready var _arena: Control = $Layout/MainRow/Arena
@onready var _player_list: VBoxContainer = $Layout/MainRow/PlayerHPPanel/PlayerList
@onready var _enemy_list: VBoxContainer = $Layout/MainRow/EnemyHPPanel/EnemyList
@onready var _lbl_round: Label = $Layout/TopBar/HBox/LblRound
@onready var _lbl_objective: Label = $Layout/TopBar/HBox/LblObjective
@onready var _lbl_turn: Label = $Layout/TopBar/HBox/LblTurn
@onready var _lbl_unit_info: Label = $Layout/BottomBar/HBox/LblUnitInfo
@onready var _btn_attack: Button = $Layout/BottomBar/HBox/BtnAttack
@onready var _btn_shove: Button = $Layout/BottomBar/HBox/BtnShove
@onready var _btn_charge: Button = $Layout/BottomBar/HBox/BtnCharge
@onready var _btn_mark: Button = $Layout/BottomBar/HBox/BtnMark
@onready var _btn_pass: Button = $Layout/BottomBar/HBox/BtnPass
@onready var _result_overlay: PanelContainer = $ResultOverlay
@onready var _lbl_result: Label = $ResultOverlay/VBox/LblResult
@onready var _lbl_contract: Label = $ResultOverlay/VBox/LblContract
@onready var _lbl_reward: Label = $ResultOverlay/VBox/LblReward
@onready var _btn_return_base: Button = $ResultOverlay/VBox/BtnReturnBase


func _ready() -> void:
	_sponsor = GameState.active_sponsor.duplicate() if not GameState.active_sponsor.is_empty() else {
		"name": "OMNICORP",
		"flavor": "",
		"requirement_kills": 3,
		"reward": 500,
		"penalty": 200,
	}
	_sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	_apply_styles()
	_build_units()
	_sort_initiative()
	await get_tree().process_frame
	await get_tree().process_frame
	_draw_arena_floor()
	_place_units()
	_draw_obstacles()
	_build_combat_log()
	_build_hp_bars()
	_btn_attack.pressed.connect(_on_attack)
	_btn_shove.pressed.connect(_on_shove)
	_btn_charge.pressed.connect(_on_charge)
	_btn_mark.pressed.connect(_on_mark)
	_btn_pass.pressed.connect(_on_pass)
	_btn_return_base.pressed.connect(_on_return_to_base)
	_update_objective_label()
	_start_turn()


func _is_obstacle(pos: Vector2i) -> bool:
	return OBSTACLE_POSITIONS.has(pos)


func _draw_obstacles() -> void:
	for pos: Vector2i in OBSTACLE_POSITIONS:
		var tile := ColorRect.new()
		tile.color = COLOR_OBSTACLE
		tile.size = MOVE_TILE_SIZE
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.position = _iso_to_screen(pos) + (UNIT_SIZE - MOVE_TILE_SIZE) * 0.5

		var border_top := ColorRect.new()
		border_top.color = COLOR_OBSTACLE_BORDER
		border_top.size = Vector2(MOVE_TILE_SIZE.x, 2)
		border_top.position = Vector2.ZERO
		border_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(border_top)

		var border_bottom := ColorRect.new()
		border_bottom.color = COLOR_OBSTACLE_BORDER
		border_bottom.size = Vector2(MOVE_TILE_SIZE.x, 2)
		border_bottom.position = Vector2(0, MOVE_TILE_SIZE.y - 2)
		border_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(border_bottom)

		var border_left := ColorRect.new()
		border_left.color = COLOR_OBSTACLE_BORDER
		border_left.size = Vector2(2, MOVE_TILE_SIZE.y)
		border_left.position = Vector2.ZERO
		border_left.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(border_left)

		var border_right := ColorRect.new()
		border_right.color = COLOR_OBSTACLE_BORDER
		border_right.size = Vector2(2, MOVE_TILE_SIZE.y)
		border_right.position = Vector2(MOVE_TILE_SIZE.x - 2, 0)
		border_right.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(border_right)

		_arena.add_child(tile)


func _draw_arena_floor() -> void:
	# Use an ArenaFloor Control subclass drawn via shader on ArenaBg
	var arena_size: Vector2 = _arena.size
	var bg := $Layout/MainRow/Arena/ArenaBg as ColorRect

	# Load or create the ellipse shader
	var shader_code := """
shader_type canvas_item;
uniform vec4 color_outer : source_color = vec4(0.10, 0.07, 0.06, 1.0);
uniform vec4 color_inner : source_color = vec4(0.15, 0.10, 0.08, 1.0);
uniform float inner_radius : hint_range(0.0, 1.0) = 0.62;
void fragment() {
	vec2 uv = UV - vec2(0.5);
	float aspect = 1.0 / (SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x);
	uv.x *= aspect;
	float d = length(uv) * 2.0;
	if (d > 1.0) {
		COLOR = vec4(0.039, 0.039, 0.059, 1.0);
	} else if (d > inner_radius) {
		COLOR = color_outer;
	} else {
		COLOR = color_inner;
	}
}
"""
	var shader := Shader.new()
	shader.code = shader_code
	var mat := ShaderMaterial.new()
	mat.shader = shader
	bg.material = mat
	bg.color = Color(1, 1, 1, 1)  # white so shader drives color
	bg.visible = true


func _build_combat_log() -> void:
	_combat_log = RichTextLabel.new()
	_combat_log.bbcode_enabled = true
	_combat_log.scroll_following = true
	_combat_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_combat_log.focus_mode = Control.FOCUS_NONE

	var arena_size: Vector2 = _arena.size
	_combat_log.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	_combat_log.offset_left = 8.0
	_combat_log.offset_bottom = -8.0
	_combat_log.offset_right = 8.0 + 280.0
	_combat_log.offset_top = -160.0

	var log_style := StyleBoxFlat.new()
	log_style.bg_color = Color(0.0, 0.0, 0.0, 0.62)
	log_style.set_border_width_all(1)
	log_style.border_color = Color(1.0, 0.133, 0.267, 0.35)
	_combat_log.add_theme_stylebox_override("normal", log_style)
	_combat_log.add_theme_font_size_override("normal_font_size", 11)

	_arena.add_child(_combat_log)


func _log(msg: String) -> void:
	if _combat_log:
		_combat_log.append_text(msg + "\n")


func _apply_styles() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.05, 0.09, 1.0)
	panel_style.border_color = Color(1.0, 0.133, 0.267, 0.6)
	panel_style.set_border_width_all(1)

	for panel: PanelContainer in [$Layout/TopBar, $Layout/BottomBar,
			$Layout/MainRow/PlayerHPPanel, $Layout/MainRow/EnemyHPPanel]:
		panel.add_theme_stylebox_override("panel", panel_style.duplicate())

	var overlay_style := StyleBoxFlat.new()
	overlay_style.bg_color = Color(0.0, 0.0, 0.0, 0.78)
	overlay_style.border_color = Color(0.0, 1.0, 0.8, 0.75)
	overlay_style.set_border_width_all(2)
	_result_overlay.add_theme_stylebox_override("panel", overlay_style)

	for lbl: Label in [$Layout/BottomBar/HBox/LblUnitInfo,
			$Layout/MainRow/PlayerHPPanel/PlayerList/LblPlayerTitle,
			$Layout/MainRow/EnemyHPPanel/EnemyList/LblEnemyTitle]:
		lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 1.0))
		lbl.add_theme_font_size_override("font_size", 14)

	# Top bar: player team name cyan, enemy team red, objective amber centre
	_lbl_round.text = "IRON LEGION"
	_lbl_round.add_theme_color_override("font_color", COLOR_PLAYER)
	_lbl_round.add_theme_font_size_override("font_size", 13)

	_lbl_turn.text = "CRIMSON VIPERS"
	_lbl_turn.add_theme_color_override("font_color", COLOR_ENEMY)
	_lbl_turn.add_theme_font_size_override("font_size", 13)

	$Layout/TopBar/HBox/LblObjective.add_theme_color_override("font_color", Color(1.0, 0.667, 0.0, 1.0))
	$Layout/TopBar/HBox/LblObjective.add_theme_font_size_override("font_size", 14)

	_style_button(_btn_attack)
	_style_button(_btn_shove)
	_style_charge_button()
	_style_mark_button()
	_style_button(_btn_pass)
	_style_button(_btn_return_base)

	$ResultOverlay/VBox.add_theme_constant_override("separation", 14)
	for lbl: Label in [_lbl_result, _lbl_contract, _lbl_reward]:
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_return_base.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	_lbl_result.add_theme_font_size_override("font_size", 48)
	_lbl_result.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_lbl_contract.add_theme_font_size_override("font_size", 24)
	_lbl_contract.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95, 1.0))
	_lbl_reward.add_theme_font_size_override("font_size", 22)
	_lbl_reward.add_theme_color_override("font_color", Color(1.0, 0.667, 0.0, 1.0))


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

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = COLOR_ATTACK_DISABLED
	disabled.border_color = Color(0.36, 0.36, 0.4, 1.0)
	disabled.set_border_width_all(2)
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.72, 0.72, 0.76, 1.0))
	btn.add_theme_font_size_override("font_size", 14)


func _style_attack_button(has_target: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = COLOR_ATTACK_READY if has_target else COLOR_ATTACK_DISABLED
	normal.border_color = COLOR_ATTACK_READY if has_target else Color(0.36, 0.36, 0.4, 1.0)
	normal.set_border_width_all(2)
	_btn_attack.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 0.22, 0.34, 1.0) if has_target else COLOR_ATTACK_DISABLED
	hover.border_color = Color(1.0, 0.45, 0.55, 1.0) if has_target else Color(0.36, 0.36, 0.4, 1.0)
	hover.set_border_width_all(2)
	_btn_attack.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.78, 0.04, 0.12, 1.0) if has_target else COLOR_ATTACK_DISABLED
	pressed.border_color = Color(1, 1, 1, 0.8) if has_target else Color(0.36, 0.36, 0.4, 1.0)
	pressed.set_border_width_all(2)
	_btn_attack.add_theme_stylebox_override("pressed", pressed)

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = COLOR_ATTACK_DISABLED
	disabled.border_color = Color(0.36, 0.36, 0.4, 1.0)
	disabled.set_border_width_all(2)
	_btn_attack.add_theme_stylebox_override("disabled", disabled)


func _style_charge_button() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.18, 0.10, 0.0, 1.0)
	normal.border_color = COLOR_CHARGE
	normal.set_border_width_all(2)
	_btn_charge.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.30, 0.18, 0.0, 1.0)
	hover.border_color = COLOR_CHARGE
	hover.set_border_width_all(2)
	_btn_charge.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.55, 0.30, 0.0, 1.0)
	pressed.border_color = Color(1, 1, 1, 0.8)
	pressed.set_border_width_all(2)
	_btn_charge.add_theme_stylebox_override("pressed", pressed)

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = COLOR_ATTACK_DISABLED
	disabled.border_color = Color(0.36, 0.36, 0.4, 1.0)
	disabled.set_border_width_all(2)
	_btn_charge.add_theme_stylebox_override("disabled", disabled)

	_btn_charge.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_btn_charge.add_theme_color_override("font_disabled_color", Color(0.72, 0.72, 0.76, 1.0))
	_btn_charge.add_theme_font_size_override("font_size", 14)


func _style_mark_button() -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.0, 0.18, 1.0)
	normal.border_color = COLOR_MARK
	normal.set_border_width_all(2)
	_btn_mark.add_theme_stylebox_override("normal", normal)

	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(0.22, 0.04, 0.30, 1.0)
	hover.border_color = COLOR_MARK
	hover.set_border_width_all(2)
	_btn_mark.add_theme_stylebox_override("hover", hover)

	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(0.45, 0.0, 0.60, 1.0)
	pressed.border_color = Color(1, 1, 1, 0.8)
	pressed.set_border_width_all(2)
	_btn_mark.add_theme_stylebox_override("pressed", pressed)

	var disabled := StyleBoxFlat.new()
	disabled.bg_color = COLOR_ATTACK_DISABLED
	disabled.border_color = Color(0.36, 0.36, 0.4, 1.0)
	disabled.set_border_width_all(2)
	_btn_mark.add_theme_stylebox_override("disabled", disabled)

	_btn_mark.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_btn_mark.add_theme_color_override("font_disabled_color", Color(0.72, 0.72, 0.76, 1.0))
	_btn_mark.add_theme_font_size_override("font_size", 14)


func _build_units() -> void:
	for i in range(GameState.roster.size()):
		var g: Dictionary = GameState.roster[i].duplicate()
		g["team"] = "player"
		g["is_mark"] = false
		g["grid_pos"] = Vector2i(i % 2, int(i / 2))
		g["hp_max"] = 20 + g["armor"] * 2
		g["hp_current"] = g["hp_max"]
		g["sprite_col"] = i % (SPRITE_COLS * SPRITE_ROWS)
		g["rect_node"] = null
		g["border_nodes"] = []
		g["hp_bar_node"] = null
		_add_combat_state(g)
		if i == 0:
			g["skill"] = "brutal_charge"
		elif i == 1:
			g["skill"] = "marksman"
			g["attack_range"] = 2
		elif i == 2:
			g["skill"] = "execution_mark"
		_units.append(g)

	var enemy_count: int = randi_range(3, 5)
	var name_pool: Array = ENEMY_NAMES.duplicate()
	name_pool.shuffle()
	var mark_name: String = _sponsor.get("requirement_target", "") if _sponsor.get("type", "") == "target" else ""
	if mark_name != "":
		name_pool.erase(mark_name)
		name_pool.insert(0, mark_name)
	for i in range(enemy_count):
		var e: Dictionary = {
			"name": name_pool[i],
			"strength": randi_range(1, 10),
			"speed": randi_range(1, 10),
			"armor": randi_range(1, 10),
			"team": "enemy",
			"is_mark": mark_name != "" and name_pool[i] == mark_name,
			"grid_pos": Vector2i(GRID_COLS - 1 - (i % 2), int(i / 2)),
			"hp_max": 0,
			"hp_current": 0,
			"sprite_col": i % (SPRITE_COLS * SPRITE_ROWS),
			"rect_node": null,
			"border_nodes": [],
			"hp_bar_node": null,
		}
		e["hp_max"] = 20 + int(e["armor"]) * 2
		e["hp_current"] = e["hp_max"]
		_add_combat_state(e)
		_units.append(e)


func _sort_initiative() -> void:
	_initiative = _units.duplicate()
	_initiative.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["speed"]) > int(b["speed"])
	)


func _add_combat_state(unit: Dictionary) -> void:
	unit["move_range"] = int(unit.get("move_range", DEFAULT_MOVE_RANGE))
	unit["attack_range"] = int(unit.get("attack_range", DEFAULT_ATTACK_RANGE))
	unit["has_moved"] = false
	unit["has_main_action"] = true
	unit["has_bonus_action"] = true


func _reset_turn_state(unit: Dictionary) -> void:
	unit["has_moved"] = false
	unit["has_main_action"] = true
	unit["has_bonus_action"] = true


func _iso_to_screen(grid_pos: Vector2i) -> Vector2:
	var arena_size: Vector2 = _arena.size
	var tile_w: float = arena_size.x / (GRID_COLS + 1.0)
	var tile_h: float = arena_size.y / (GRID_ROWS + 2.0)
	var cx: float = arena_size.x * 0.5
	var cy: float = arena_size.y * 0.35
	var x: float = cx + (grid_pos.x - grid_pos.y) * tile_w * 0.5
	var y: float = cy + (grid_pos.x + grid_pos.y) * tile_h * 0.4
	return Vector2(x - UNIT_SIZE.x * 0.5, y - UNIT_SIZE.y * 0.5)


func _get_active_unit() -> Dictionary:
	if _battle_over or _initiative.is_empty():
		return {}
	return _initiative[_turn_index]


func _is_in_grid(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < GRID_COLS and grid_pos.y >= 0 and grid_pos.y < GRID_ROWS


func _grid_distance(a: Vector2i, b: Vector2i) -> int:
	return absi(a.x - b.x) + absi(a.y - b.y)


func _is_tile_occupied(grid_pos: Vector2i, ignored_unit = null) -> bool:
	for unit: Dictionary in _units:
		if unit == ignored_unit:
			continue
		if int(unit.get("hp_current", 0)) <= 0:
			continue
		if unit.get("grid_pos", Vector2i(-1, -1)) == grid_pos:
			return true
	return false


func _is_in_attack_range(attacker: Dictionary, target: Dictionary) -> bool:
	if attacker.is_empty() or target.is_empty():
		return false
	var attacker_pos: Vector2i = attacker.get("grid_pos", Vector2i(-1, -1))
	var target_pos: Vector2i = target.get("grid_pos", Vector2i(-1, -1))
	return _grid_distance(attacker_pos, target_pos) <= int(attacker.get("attack_range", DEFAULT_ATTACK_RANGE))


func _get_reachable_tiles(unit: Dictionary) -> Array:
	var result: Array = []
	if unit.is_empty() or bool(unit.get("has_moved", false)):
		return result

	var origin: Vector2i = unit["grid_pos"]
	var move_range: int = int(unit.get("move_range", DEFAULT_MOVE_RANGE))
	for y in range(GRID_ROWS):
		for x in range(GRID_COLS):
			var pos := Vector2i(x, y)
			var distance := _grid_distance(origin, pos)
			if distance == 0 or distance > move_range:
				continue
			if _is_tile_occupied(pos, unit) or _is_obstacle(pos):
				continue
			result.append(pos)
	return result


func _set_unit_screen_position(unit: Dictionary) -> void:
	if unit.get("rect_node", null) == null:
		return
	var rect := unit["rect_node"] as Control
	rect.position = _iso_to_screen(unit["grid_pos"])


func _move_unit_to(unit: Dictionary, grid_pos: Vector2i) -> void:
	unit["grid_pos"] = grid_pos
	_set_unit_screen_position(unit)


func _make_unit_texture(sprite_index: int) -> AtlasTexture:
	var col := sprite_index % SPRITE_COLS
	var row := (sprite_index / SPRITE_COLS) % SPRITE_ROWS
	var atlas := AtlasTexture.new()
	atlas.atlas = _sprite_sheet
	atlas.region = Rect2(
		col * SPRITE_FRAME_W,
		row * SPRITE_FRAME_H,
		SPRITE_FRAME_W,
		SPRITE_FRAME_H
	)
	return atlas


func _place_units() -> void:
	for unit: Dictionary in _units:
		var tex_rect := TextureRect.new()
		tex_rect.custom_minimum_size = UNIT_SIZE
		tex_rect.size = UNIT_SIZE
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.position = _iso_to_screen(unit["grid_pos"])
		tex_rect.mouse_filter = Control.MOUSE_FILTER_STOP

		if _sprite_sheet:
			tex_rect.texture = _make_unit_texture(unit["sprite_col"])

		tex_rect.mouse_default_cursor_shape = Control.CURSOR_ARROW
		tex_rect.gui_input.connect(_on_unit_gui_input.bind(unit))
		tex_rect.mouse_entered.connect(_on_unit_mouse_entered.bind(unit))
		tex_rect.mouse_exited.connect(_on_unit_mouse_exited.bind(unit))
		_arena.add_child(tex_rect)
		unit["rect_node"] = tex_rect
		unit["border_nodes"] = _create_unit_borders(tex_rect)


func _show_move_tiles(unit: Dictionary) -> void:
	_clear_move_tiles()
	if not _is_player_turn() or bool(unit.get("has_moved", false)):
		return

	for grid_pos: Vector2i in _get_reachable_tiles(unit):
		var tile := ColorRect.new()
		tile.color = COLOR_MOVE_TILE
		tile.size = MOVE_TILE_SIZE
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tile.position = _iso_to_screen(grid_pos) + (UNIT_SIZE - MOVE_TILE_SIZE) * 0.5
		tile.gui_input.connect(_on_move_tile_gui_input.bind(grid_pos))
		tile.mouse_entered.connect(_on_move_tile_mouse_entered.bind(tile))
		tile.mouse_exited.connect(_on_move_tile_mouse_exited.bind(tile))
		_arena.add_child(tile)
		_move_tiles.append(tile)


func _clear_move_tiles() -> void:
	for tile: ColorRect in _move_tiles:
		if is_instance_valid(tile):
			tile.queue_free()
	_move_tiles.clear()


func _show_attack_range_tiles(unit: Dictionary) -> void:
	_clear_attack_range_tiles()
	var atk_range: int = int(unit.get("attack_range", DEFAULT_ATTACK_RANGE))
	if atk_range <= 1 or not _is_player_turn():
		return
	for u: Dictionary in _units:
		if u["team"] != "enemy" or int(u.get("hp_current", 0)) <= 0:
			continue
		if _grid_distance(unit["grid_pos"], u["grid_pos"]) > atk_range:
			continue
		var tile := ColorRect.new()
		tile.color = Color(1.0, 0.133, 0.267, 0.18)
		tile.size = MOVE_TILE_SIZE
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.position = _iso_to_screen(u["grid_pos"]) + (UNIT_SIZE - MOVE_TILE_SIZE) * 0.5
		_arena.add_child(tile)
		_attack_range_tiles.append(tile)


func _clear_attack_range_tiles() -> void:
	for tile: ColorRect in _attack_range_tiles:
		if is_instance_valid(tile):
			tile.queue_free()
	_attack_range_tiles.clear()


func _is_reachable_tile(unit: Dictionary, grid_pos: Vector2i) -> bool:
	return _get_reachable_tiles(unit).has(grid_pos)


func _on_move_tile_gui_input(event: InputEvent, grid_pos: Vector2i) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	if not _is_player_turn():
		return

	var unit := _get_active_unit()
	if unit.is_empty() or not _is_reachable_tile(unit, grid_pos):
		return

	_move_unit_to(unit, grid_pos)
	unit["has_moved"] = true
	_log("[color=#00ffcc]%s[/color] repositioned" % unit["name"])
	_clear_move_tiles()
	_clear_target_selection(false)
	_update_unit_info(unit)
	_update_targeting_enabled()
	_update_attack_button_state()
	_update_shove_button_state()
	_update_charge_button_state()
	_update_mark_button_state()
	_show_attack_range_tiles(unit)
	_highlight_active(unit)
	accept_event()


func _on_move_tile_mouse_entered(tile: ColorRect) -> void:
	tile.color = COLOR_MOVE_TILE_HOVER


func _on_move_tile_mouse_exited(tile: ColorRect) -> void:
	tile.color = COLOR_MOVE_TILE


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


func _update_objective_label() -> void:
	var sponsor_name: String = _sponsor.get("name", "SPONSOR")
	match _sponsor.get("type", "kills"):
		"style":
			var req_rounds: int = int(_sponsor.get("requirement_rounds", 1))
			_lbl_objective.text = "ROUND %d  |  %s: WIN IN ≤ %d ROUNDS" % [
				_round, sponsor_name, req_rounds
			]
		"target":
			var target_name: String = _sponsor.get("requirement_target", "?")
			var status: String = "ELIMINATED" if _mark_killed else "ALIVE"
			_lbl_objective.text = "ROUND %d  |  %s: EXECUTE %s  [%s]" % [
				_round, sponsor_name, target_name, status
			]
		_:
			var req: int = int(_sponsor.get("requirement_kills", 0))
			var style_tag := "  STYLE: %d" % _style_score if _style_score > 0 else ""
			_lbl_objective.text = "ROUND %d  |  %s: KILL %d  [%d/%d]%s" % [
				_round, sponsor_name, req, _kills, req, style_tag
			]


func _update_unit_info(unit: Dictionary) -> void:
	var move_state := "USED" if bool(unit.get("has_moved", false)) else "READY"
	var action_state := "READY" if bool(unit.get("has_main_action", true)) else "USED"
	var bonus_state := "SHOVE" if bool(unit.get("has_bonus_action", true)) else "USED"
	var skill_part := ""
	match unit.get("skill", ""):
		"brutal_charge":
			var charge_ready := bool(unit.get("has_main_action", true)) and not bool(unit.get("has_moved", false))
			skill_part = "  SKILL: %s" % ("CHARGE" if charge_ready else "USED")
		"marksman":
			var atk_ready := bool(unit.get("has_main_action", true))
			skill_part = "  SKILL: MARKSMAN (RANGE 2)%s" % ("" if atk_ready else "  ACTION USED")
		"execution_mark":
			var bonus_ready := bool(unit.get("has_bonus_action", true))
			skill_part = "  SKILL: MARK (%s)" % ("READY" if bonus_ready else "USED")
	_lbl_unit_info.text = "%s  |  HP %d/%d  STR %d  SPD %d  ARM %d  |  MOVE: %s  ACTION: %s  BONUS: %s%s" % [
		unit["name"],
		unit["hp_current"], unit["hp_max"],
		unit["strength"], unit["speed"], unit["armor"],
		move_state, action_state, bonus_state, skill_part
	]


func _start_turn() -> void:
	if _battle_over or _initiative.is_empty():
		return

	_clear_target_selection(false)
	_clear_move_tiles()
	_clear_attack_range_tiles()
	var unit: Dictionary = _initiative[_turn_index]
	_reset_turn_state(unit)
	_update_objective_label()
	_update_unit_info(unit)

	_highlight_active(unit)

	var is_player_turn: bool = str(unit["team"]) == "player"
	_btn_pass.disabled = not is_player_turn
	_update_targeting_enabled()
	_update_attack_button_state()
	_update_shove_button_state()
	_update_charge_button_state()
	_update_mark_button_state()
	if is_player_turn:
		_show_move_tiles(unit)
		_show_attack_range_tiles(unit)

	if not is_player_turn:
		await get_tree().create_timer(0.6).timeout
		_enemy_act(unit)


func _highlight_active(active_unit: Dictionary) -> void:
	for unit: Dictionary in _units:
		if unit["rect_node"] == null:
			continue
		_update_unit_visual(unit, active_unit)


func _create_unit_borders(rect: Control) -> Array:
	var borders: Array = []
	for border_name in ["BorderTop", "BorderRight", "BorderBottom", "BorderLeft"]:
		var border := ColorRect.new()
		border.name = border_name
		border.color = COLOR_TRANSPARENT
		border.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.add_child(border)
		borders.append(border)
	return borders


func _set_unit_border(unit: Dictionary, color: Color, width: int) -> void:
	var borders: Array = unit.get("border_nodes", [])
	if borders.size() != 4:
		return

	var rect := unit["rect_node"] as Control
	var w := float(width)
	var top := borders[0] as ColorRect
	var right := borders[1] as ColorRect
	var bottom := borders[2] as ColorRect
	var left := borders[3] as ColorRect
	for border: ColorRect in [top, right, bottom, left]:
		border.color = color
		border.visible = width > 0

	top.position = Vector2.ZERO
	top.size = Vector2(rect.size.x, w)
	right.position = Vector2(rect.size.x - w, 0)
	right.size = Vector2(w, rect.size.y)
	bottom.position = Vector2(0, rect.size.y - w)
	bottom.size = Vector2(rect.size.x, w)
	left.position = Vector2.ZERO
	left.size = Vector2(w, rect.size.y)


func _update_unit_visual(unit: Dictionary, active_unit: Dictionary) -> void:
	var tex_rect := unit["rect_node"] as TextureRect
	if unit == _hovered_target and _is_targetable(unit):
		tex_rect.modulate = Color(1.3, 1.3, 1.3, 1.0)
	else:
		tex_rect.modulate = Color(1, 1, 1, 1)

	if unit == _selected_target and _is_valid_target(unit):
		_set_unit_border(unit, COLOR_SELECTED_BORDER, 3)
	elif unit == _hovered_target and _is_targetable(unit):
		_set_unit_border(unit, COLOR_HOVER_BORDER, 2)
	elif unit == active_unit:
		_set_unit_border(unit, COLOR_ACTIVE_BORDER, 2)
	elif unit.get("is_mark", false) and int(unit.get("hp_current", 0)) > 0:
		_set_unit_border(unit, Color(1.0, 0.667, 0.0, 0.9), 2)
	else:
		_set_unit_border(unit, COLOR_TRANSPARENT, 0)


func _is_player_turn() -> bool:
	if _battle_over or _initiative.is_empty():
		return false
	return str(_initiative[_turn_index]["team"]) == "player"


func _is_targetable(unit: Dictionary) -> bool:
	if not _is_player_turn() or str(unit["team"]) != "enemy" or int(unit["hp_current"]) <= 0:
		return false
	var active := _get_active_unit()
	return not active.is_empty() and bool(active.get("has_main_action", true)) and _is_in_attack_range(active, unit)


func _is_valid_target(target) -> bool:
	if not (target is Dictionary):
		return false
	if not _units.has(target) or str(target.get("team", "")) != "enemy" or int(target.get("hp_current", 0)) <= 0:
		return false
	var active := _get_active_unit()
	return not active.is_empty() and bool(active.get("has_main_action", true)) and _is_in_attack_range(active, target)


func _update_targeting_enabled() -> void:
	for unit: Dictionary in _units:
		if unit["rect_node"] == null:
			continue
		var rect := unit["rect_node"] as Control
		var targetable: bool = _is_targetable(unit)
		rect.mouse_filter = Control.MOUSE_FILTER_STOP if targetable else Control.MOUSE_FILTER_IGNORE
		rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if targetable else Control.CURSOR_ARROW


func _update_attack_button_state() -> void:
	if _battle_over or _initiative.is_empty():
		_btn_attack.disabled = true
		_btn_attack.text = "ATTACK"
		_style_attack_button(false)
		return

	var active := _get_active_unit()
	var has_action: bool = active.is_empty() or bool(active.get("has_main_action", true))
	var has_target: bool = _is_valid_target(_selected_target)
	if _is_player_turn():
		_btn_attack.disabled = not has_target
		if not has_action:
			_btn_attack.text = "ACTION USED"
		else:
			_btn_attack.text = "ATTACK" if has_target else "SELECT ADJACENT TARGET"
		_style_attack_button(has_target)
	else:
		_btn_attack.disabled = true
		_btn_attack.text = "ATTACK"
		_style_attack_button(false)


func _get_adjacent_enemy(unit: Dictionary) -> Dictionary:
	for u: Dictionary in _units:
		if u["team"] == "enemy" and int(u.get("hp_current", 0)) > 0:
			if _grid_distance(unit["grid_pos"], u["grid_pos"]) == 1:
				return u
	return {}


func _update_shove_button_state() -> void:
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		_btn_shove.disabled = true
		_btn_shove.text = "SHOVE"
		return

	var active := _get_active_unit()
	if active.is_empty() or not bool(active.get("has_bonus_action", true)):
		_btn_shove.disabled = true
		_btn_shove.text = "BONUS USED"
		return

	var has_adjacent := not _get_adjacent_enemy(active).is_empty()
	_btn_shove.disabled = not has_adjacent
	_btn_shove.text = "SHOVE" if has_adjacent else "SHOVE (NO TARGET)"


func _update_charge_button_state() -> void:
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		_btn_charge.disabled = true
		_btn_charge.visible = false
		return

	var active := _get_active_unit()
	if active.is_empty() or active.get("skill", "") != "brutal_charge":
		_btn_charge.disabled = true
		_btn_charge.visible = false
		return

	_btn_charge.visible = true
	var can_charge := bool(active.get("has_main_action", true)) and not bool(active.get("has_moved", false))
	var has_target := not _get_charge_target(active).is_empty()
	_btn_charge.disabled = not (can_charge and has_target)
	if not bool(active.get("has_main_action", true)):
		_btn_charge.text = "ACTION USED"
	elif bool(active.get("has_moved", false)):
		_btn_charge.text = "CHARGE (MOVED)"
	elif not has_target:
		_btn_charge.text = "CHARGE (NO PATH)"
	else:
		_btn_charge.text = "CHARGE"


func _update_mark_button_state() -> void:
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		_btn_mark.disabled = true
		_btn_mark.visible = false
		return

	var active := _get_active_unit()
	if active.is_empty() or active.get("skill", "") != "execution_mark":
		_btn_mark.disabled = true
		_btn_mark.visible = false
		return

	_btn_mark.visible = true
	if not bool(active.get("has_bonus_action", true)):
		_btn_mark.disabled = true
		_btn_mark.text = "BONUS USED"
		return

	var target := _get_mark_target(active)
	_btn_mark.disabled = target.is_empty()
	_btn_mark.text = "MARK" if not target.is_empty() else "MARK (NO TARGET)"


func _get_mark_target(unit: Dictionary) -> Dictionary:
	# Returns the selected target if it's an adjacent wounded enemy, else first adjacent wounded enemy.
	var check_units: Array = []
	if _selected_target is Dictionary and not _selected_target.is_empty():
		check_units = [_selected_target]
	for u: Dictionary in _units:
		if not check_units.has(u):
			check_units.append(u)
	for u: Dictionary in check_units:
		if u["team"] != "enemy" or int(u.get("hp_current", 0)) <= 0:
			continue
		if _grid_distance(unit["grid_pos"], u["grid_pos"]) > 1:
			continue
		var hp_pct := float(u["hp_current"]) / float(u["hp_max"])
		if hp_pct < 0.5:
			return u
	return {}


func _on_mark() -> void:
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		return

	var unit := _get_active_unit()
	if unit.is_empty() or unit.get("skill", "") != "execution_mark":
		return
	if not bool(unit.get("has_bonus_action", true)):
		return

	var target := _get_mark_target(unit)
	if target.is_empty():
		return

	unit["has_bonus_action"] = false
	_marked_unit = target
	_log("[color=#cc44ff]%s[/color] MARKED [color=#ff2244]%s[/color] for execution!" % [unit["name"], target["name"]])
	_update_unit_info(unit)
	_update_mark_button_state()
	_update_shove_button_state()


func _get_charge_target(unit: Dictionary) -> Dictionary:
	var pos: Vector2i = unit["grid_pos"]
	var move_range: int = int(unit.get("move_range", DEFAULT_MOVE_RANGE))
	# Charge fires in the direction of the nearest enemy (by col delta sign).
	var live_enemies: Array = _units.filter(func(u: Dictionary) -> bool:
		return u["team"] == "enemy" and int(u.get("hp_current", 0)) > 0
	)
	if live_enemies.is_empty():
		return {}
	var nearest := _find_nearest(unit, live_enemies)
	if nearest.is_empty():
		return {}
	var dx: int = sign(nearest["grid_pos"].x - pos.x)
	var dy: int = sign(nearest["grid_pos"].y - pos.y)
	# Prefer column direction; if same column, use row direction.
	if dx == 0 and dy == 0:
		return {}
	var step := Vector2i(dx, 0) if dx != 0 else Vector2i(0, dy)
	for dist in range(1, move_range + 2):
		var check := pos + step * dist
		if not _is_in_grid(check):
			break
		if _is_obstacle(check):
			break
		for u: Dictionary in _units:
			if u["team"] == "enemy" and int(u.get("hp_current", 0)) > 0 and u["grid_pos"] == check:
				return u
	return {}


func _on_charge() -> void:
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		return

	var unit := _get_active_unit()
	if unit.is_empty() or unit.get("skill", "") != "brutal_charge":
		return
	if not bool(unit.get("has_main_action", true)) or bool(unit.get("has_moved", false)):
		return

	var target := _get_charge_target(unit)
	if target.is_empty():
		return

	# Step toward target, stop one tile before, then attack.
	var pos: Vector2i = unit["grid_pos"]
	var dx: int = sign(target["grid_pos"].x - pos.x)
	var dy: int = sign(target["grid_pos"].y - pos.y)
	var step := Vector2i(dx, 0) if dx != 0 else Vector2i(0, dy)
	var land := pos
	for dist in range(1, int(unit.get("move_range", DEFAULT_MOVE_RANGE)) + 1):
		var next := pos + step * dist
		if not _is_in_grid(next) or _is_obstacle(next) or _is_tile_occupied(next, unit):
			break
		land = next

	unit["has_moved"] = true
	unit["has_main_action"] = false
	_move_unit_to(unit, land)
	_clear_move_tiles()
	_update_unit_info(unit)
	_update_charge_button_state()
	_update_attack_button_state()
	_update_shove_button_state()
	_update_mark_button_state()

	_log("[color=#ffaa00]%s[/color] [color=#00ffcc]CHARGES![/color]" % unit["name"])
	await _apply_attack_direct(unit, target)


func _apply_attack_direct(attacker: Dictionary, target: Dictionary) -> void:
	var base_damage: int = maxi(1, int(attacker["strength"]) - int(target["armor"]))
	var flanked := _is_flanked(attacker, target)
	var damage := base_damage + (FLANK_BONUS if flanked else 0)
	var attacker_color := "[color=#ffaa00]"
	var target_color := "[color=#00ffcc]" if target["team"] == "player" else "[color=#ff2244]"
	var flank_tag := "  [color=#ffaa00][FLANK +%d][/color]" % FLANK_BONUS if flanked else ""
	var mark_tag := "  [color=#cc44ff][MARKED +%d][/color]" % MARK_BONUS if target == _marked_unit else ""
	_log("%s%s[/color] hit %s%s[/color] for [color=#ffaa00]%d[/color] dmg%s%s" % [
		attacker_color, attacker["name"],
		target_color, target["name"],
		damage, flank_tag, mark_tag
	])
	var killed := await _apply_damage(target, damage)
	if killed and _check_battle_end():
		return
	_advance_turn()


func _on_shove() -> void:
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		return

	var unit := _get_active_unit()
	if unit.is_empty() or not bool(unit.get("has_bonus_action", true)):
		return

	var target := _get_adjacent_enemy(unit)
	if target.is_empty():
		return

	unit["has_bonus_action"] = false

	var push_dir: Vector2i = target["grid_pos"] - unit["grid_pos"]
	var dest: Vector2i = target["grid_pos"] + push_dir

	if _is_in_grid(dest) and not _is_tile_occupied(dest, target) and not _is_obstacle(dest):
		_move_unit_to(target, dest)
		_log("[color=#00ffcc]%s[/color] shoved [color=#ff2244]%s[/color] back!" % [unit["name"], target["name"]])
	else:
		var wall_damage := 2
		_log("[color=#00ffcc]%s[/color] slammed [color=#ff2244]%s[/color] into the wall — [color=#ffaa00]%d[/color] dmg!" % [
			unit["name"], target["name"], wall_damage
		])
		var killed := await _apply_damage(target, wall_damage)
		if killed and _check_battle_end():
			return

	_update_unit_info(unit)
	_update_shove_button_state()
	_update_mark_button_state()


func _clear_target_selection(update_button := true) -> void:
	_selected_target = null
	_hovered_target = null
	if update_button:
		_update_attack_button_state()
		if not _initiative.is_empty():
			_highlight_active(_initiative[_turn_index])


func _on_unit_gui_input(event: InputEvent, unit: Dictionary) -> void:
	if not _is_targetable(unit):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_selected_target = unit
		_update_attack_button_state()
		_highlight_active(_initiative[_turn_index])
		accept_event()


func _on_unit_mouse_entered(unit: Dictionary) -> void:
	if not _is_targetable(unit):
		return
	_hovered_target = unit
	_highlight_active(_initiative[_turn_index])


func _on_unit_mouse_exited(unit: Dictionary) -> void:
	if _hovered_target != unit:
		return
	_hovered_target = null
	_highlight_active(_initiative[_turn_index])


func _enemy_act(unit: Dictionary) -> void:
	var targets: Array = []
	for u: Dictionary in _units:
		if u["team"] == "player" and int(u["hp_current"]) > 0:
			targets.append(u)
	if targets.is_empty():
		_advance_turn()
		return

	var target: Dictionary = _find_nearest(unit, targets)
	if not _is_in_attack_range(unit, target):
		var destination := _get_enemy_move_destination(unit, target)
		if destination != unit["grid_pos"]:
			_move_unit_to(unit, destination)
			unit["has_moved"] = true
			_log("[color=#ff2244]%s[/color] advanced" % unit["name"])

	if _is_in_attack_range(unit, target):
		unit["has_main_action"] = false
		_apply_attack(unit, target)
	else:
		_advance_turn()


func _on_attack() -> void:
	if _battle_over or _initiative.is_empty():
		return
	var unit: Dictionary = _initiative[_turn_index]
	if not _is_player_turn():
		return
	if not _is_valid_target(_selected_target):
		_update_attack_button_state()
		return

	var target: Dictionary = _selected_target
	unit["has_main_action"] = false
	_update_unit_info(unit)
	_update_shove_button_state()
	_update_charge_button_state()
	_update_mark_button_state()
	_clear_move_tiles()
	_clear_target_selection()
	_apply_attack(unit, target)


func _on_pass() -> void:
	if _battle_over:
		return
	_advance_turn()


func _find_nearest(attacker: Dictionary, candidates: Array) -> Dictionary:
	var best: Dictionary = candidates[0]
	var best_dist: int = 999
	for c: Dictionary in candidates:
		var ap: Vector2i = attacker["grid_pos"]
		var cp: Vector2i = c["grid_pos"]
		var d: int = _grid_distance(ap, cp)
		if d < best_dist:
			best_dist = d
			best = c
	return best


func _get_enemy_move_destination(unit: Dictionary, target: Dictionary) -> Vector2i:
	var best_pos: Vector2i = unit["grid_pos"]
	var best_dist: int = _grid_distance(unit["grid_pos"], target["grid_pos"])
	for pos: Vector2i in _get_reachable_tiles(unit):
		var dist := _grid_distance(pos, target["grid_pos"])
		if dist < best_dist:
			best_dist = dist
			best_pos = pos
	return best_pos


func _apply_damage(target: Dictionary, amount: int) -> bool:
	var mark_bonus := MARK_BONUS if target == _marked_unit else 0
	target["hp_current"] = maxi(0, int(target["hp_current"]) - (amount + mark_bonus))
	if target["hp_bar_node"] != null:
		(target["hp_bar_node"] as ProgressBar).value = target["hp_current"]
	_flash_hit(target)
	if int(target["hp_current"]) <= 0:
		var target_color := "[color=#00ffcc]" if target["team"] == "player" else "[color=#ff2244]"
		_log("%s%s[/color] [color=#888888]was eliminated[/color]" % [target_color, target["name"]])
		if str(target["team"]) == "enemy":
			_kills += 1
			if target.get("is_mark", false):
				_mark_killed = true
			if target == _marked_unit:
				_style_score += 1
				_log("[color=#cc44ff]EXECUTION — STYLE +1[/color]")
			_update_objective_label()
		await get_tree().create_timer(0.25).timeout
		_remove_dead(target)
		return true
	return false


func _is_flanked(attacker: Dictionary, target: Dictionary) -> bool:
	var flank_pos: Vector2i = target["grid_pos"] + (target["grid_pos"] - attacker["grid_pos"])
	for u: Dictionary in _units:
		if u == attacker or int(u.get("hp_current", 0)) <= 0:
			continue
		if u["team"] == attacker["team"] and u["grid_pos"] == flank_pos:
			return true
	return false


func _apply_attack(attacker: Dictionary, target: Dictionary) -> void:
	var base_damage: int = maxi(1, int(attacker["strength"]) - int(target["armor"]))
	var flanked := _is_flanked(attacker, target)
	var damage := base_damage + (FLANK_BONUS if flanked else 0)
	var attacker_color := "[color=#00ffcc]" if attacker["team"] == "player" else "[color=#ff2244]"
	var target_color := "[color=#00ffcc]" if target["team"] == "player" else "[color=#ff2244]"
	var flank_tag := "  [color=#ffaa00][FLANK +%d][/color]" % FLANK_BONUS if flanked else ""
	var mark_tag := "  [color=#cc44ff][MARKED +%d][/color]" % MARK_BONUS if target == _marked_unit else ""
	_log("%s%s[/color] hit %s%s[/color] for [color=#ffaa00]%d[/color] dmg%s%s" % [
		attacker_color, attacker["name"],
		target_color, target["name"],
		damage, flank_tag, mark_tag
	])
	var killed := await _apply_damage(target, damage)
	if killed and _check_battle_end():
		return
	_advance_turn()


func _flash_hit(unit: Dictionary) -> void:
	if unit["rect_node"] == null:
		return
	var tex_rect := unit["rect_node"] as TextureRect
	var tween := create_tween()
	tween.tween_property(tex_rect, "modulate", Color(1, 1, 1, 1), 0.08)
	tween.tween_property(tex_rect, "modulate", Color(1, 1, 1, 1), 0.12)


func _remove_dead(unit: Dictionary) -> void:
	if unit["rect_node"] != null:
		(unit["rect_node"] as TextureRect).queue_free()
		unit["rect_node"] = null
		unit["border_nodes"] = []
	if unit["hp_bar_node"] != null:
		(unit["hp_bar_node"] as ProgressBar).get_parent().queue_free()
		unit["hp_bar_node"] = null
	if _selected_target == unit:
		_selected_target = null
	if _hovered_target == unit:
		_hovered_target = null
	if _marked_unit == unit:
		_marked_unit = null
	_units.erase(unit)
	_initiative.erase(unit)
	if _turn_index >= _initiative.size():
		_turn_index = 0


func _advance_turn() -> void:
	if _initiative.is_empty():
		return
	_clear_target_selection(false)
	_clear_move_tiles()
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
	_btn_shove.disabled = true
	_btn_mark.disabled = true
	_btn_pass.disabled = true
	_clear_move_tiles()
	_clear_attack_range_tiles()
	_clear_target_selection()
	_result_overlay.visible = true

	var reward: int = int(_sponsor.get("reward", 500))
	var penalty: int = int(_sponsor.get("penalty", 200))
	var sponsor_name: String = _sponsor.get("name", "SPONSOR")
	var contract_type: String = _sponsor.get("type", "kills")

	var contract_met: bool
	var contract_detail: String
	match contract_type:
		"style":
			var req_rounds: int = int(_sponsor.get("requirement_rounds", 1))
			contract_met = won and _round <= req_rounds
			contract_detail = "(%d/%d ROUNDS)" % [_round, req_rounds]
		"target":
			var target_name: String = _sponsor.get("requirement_target", "TARGET")
			contract_met = won and _mark_killed
			contract_detail = "(%s %s)" % [target_name, "ELIMINATED" if _mark_killed else "SURVIVED"]
		_:
			var req_kills: int = int(_sponsor.get("requirement_kills", 0))
			contract_met = won and _kills >= req_kills
			contract_detail = "(%d/%d KILLS)" % [_kills, req_kills]

	if won:
		_lbl_result.text = "VICTORY"
		_lbl_result.add_theme_color_override("font_color", COLOR_PLAYER)
		if contract_met:
			_lbl_contract.text = "%s CONTRACT FULFILLED  %s" % [sponsor_name, contract_detail]
			GameState.credits += reward
			_lbl_reward.text = "+%d CREDITS" % reward
		else:
			_lbl_contract.text = "%s CONTRACT FAILED  %s" % [sponsor_name, contract_detail]
			GameState.credits -= penalty
			_lbl_reward.text = "-%d CREDITS" % penalty
	else:
		_lbl_result.text = "DEFEAT"
		_lbl_result.add_theme_color_override("font_color", COLOR_ENEMY)
		_lbl_contract.text = "%s CONTRACT FAILED  %s" % [sponsor_name, contract_detail]
		GameState.credits -= penalty
		_lbl_reward.text = "-%d CREDITS" % penalty
	GameState.save_game()


func _on_return_to_base() -> void:
	get_tree().change_scene_to_file("res://scenes/Management.tscn")
