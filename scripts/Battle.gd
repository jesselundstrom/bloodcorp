extends Control

const ENEMY_NAMES := [
	"GRAK", "VOSS", "ZARETH", "NAXIS", "KRUL", "THANE", "OREX", "VELD",
	"CRUX", "MORD", "SLASH", "BONE", "WREX", "DRAK", "TYKE", "SORN",
	"KAEL", "RAZE", "FLUX", "TOMB", "VEX", "GORN", "BLUD", "KRIX"
]

const SPONSOR_NAME := "OMNICORP"
const SPONSOR_REQUIREMENT := "eliminate all enemies"
const SPONSOR_REWARD := 500
const SPONSOR_PENALTY := 200

const GRID_COLS := 5
const GRID_ROWS := 4
const UNIT_SIZE := Vector2(56, 56)

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
const COLOR_TRANSPARENT := Color(0, 0, 0, 0)

var _units: Array = []
var _initiative: Array = []
var _turn_index: int = 0
var _round: int = 1
var _battle_over: bool = false
var _selected_target = null
var _hovered_target = null
var _sprite_sheet: Texture2D = null
var _combat_log: RichTextLabel = null

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
@onready var _lbl_contract: Label = $ResultOverlay/VBox/LblContract
@onready var _lbl_reward: Label = $ResultOverlay/VBox/LblReward
@onready var _btn_return_base: Button = $ResultOverlay/VBox/BtnReturnBase


func _ready() -> void:
	_sprite_sheet = load(SPRITE_SHEET_PATH) as Texture2D
	_apply_styles()
	_build_units()
	_sort_initiative()
	await get_tree().process_frame
	await get_tree().process_frame
	_draw_arena_floor()
	_place_units()
	_build_combat_log()
	_build_hp_bars()
	_btn_attack.pressed.connect(_on_attack)
	_btn_pass.pressed.connect(_on_pass)
	_btn_return_base.pressed.connect(_on_return_to_base)
	_lbl_objective.text = "%s CONTRACT: %s" % [SPONSOR_NAME, SPONSOR_REQUIREMENT.to_upper()]
	_start_turn()


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


func _build_units() -> void:
	for i in range(GameState.roster.size()):
		var g: Dictionary = GameState.roster[i].duplicate()
		g["team"] = "player"
		g["grid_pos"] = Vector2i(i % 2, i)
		g["hp_max"] = 20 + g["armor"] * 2
		g["hp_current"] = g["hp_max"]
		g["sprite_col"] = i % (SPRITE_COLS * SPRITE_ROWS)
		g["rect_node"] = null
		g["border_nodes"] = []
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
			"sprite_col": i % (SPRITE_COLS * SPRITE_ROWS),
			"rect_node": null,
			"border_nodes": [],
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

	_clear_target_selection(false)
	var unit: Dictionary = _initiative[_turn_index]
	_lbl_objective.text = "ROUND %d  |  %s CONTRACT: %s" % [_round, SPONSOR_NAME, SPONSOR_REQUIREMENT.to_upper()]
	# Update team label to highlight whose turn it is
	_lbl_unit_info.text = "%s  STR:%d  SPD:%d  ARM:%d  HP:%d/%d" % [
		unit["name"], unit["strength"], unit["speed"],
		unit["armor"], unit["hp_current"], unit["hp_max"]
	]

	_highlight_active(unit)

	var is_player_turn: bool = str(unit["team"]) == "player"
	_btn_pass.disabled = not is_player_turn
	_update_targeting_enabled()
	_update_attack_button_state()

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
	else:
		_set_unit_border(unit, COLOR_TRANSPARENT, 0)


func _is_player_turn() -> bool:
	if _battle_over or _initiative.is_empty():
		return false
	return str(_initiative[_turn_index]["team"]) == "player"


func _is_targetable(unit: Dictionary) -> bool:
	return _is_player_turn() and str(unit["team"]) == "enemy" and int(unit["hp_current"]) > 0


func _is_valid_target(target) -> bool:
	if not (target is Dictionary):
		return false
	return _units.has(target) and str(target.get("team", "")) == "enemy" and int(target.get("hp_current", 0)) > 0


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

	var has_target: bool = _is_valid_target(_selected_target)
	if _is_player_turn():
		_btn_attack.disabled = not has_target
		_btn_attack.text = "ATTACK" if has_target else "SELECT TARGET"
		_style_attack_button(has_target)
	else:
		_btn_attack.disabled = true
		_btn_attack.text = "ATTACK"
		_style_attack_button(false)


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
	_apply_attack(unit, target)


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
	_clear_target_selection()
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

	# Combat log entry
	var attacker_color := "[color=#00ffcc]" if attacker["team"] == "player" else "[color=#ff2244]"
	var target_color := "[color=#00ffcc]" if target["team"] == "player" else "[color=#ff2244]"
	_log("%s%s[/color] hit %s%s[/color] for [color=#ffaa00]%d[/color] dmg" % [
		attacker_color, attacker["name"],
		target_color, target["name"],
		damage
	])

	_flash_hit(target)

	if int(target["hp_current"]) <= 0:
		_log("%s%s[/color] [color=#888888]was eliminated[/color]" % [target_color, target["name"]])
		await get_tree().create_timer(0.25).timeout
		_remove_dead(target)
		if _check_battle_end():
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
	_units.erase(unit)
	_initiative.erase(unit)
	if _turn_index >= _initiative.size():
		_turn_index = 0


func _advance_turn() -> void:
	if _initiative.is_empty():
		return
	_clear_target_selection(false)
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
	_clear_target_selection()
	_result_overlay.visible = true

	if won:
		_lbl_result.text = "VICTORY"
		_lbl_result.add_theme_color_override("font_color", COLOR_PLAYER)
		_lbl_contract.text = "CONTRACT FULFILLED"
		GameState.credits += SPONSOR_REWARD
		_lbl_reward.text = "+%d CREDITS" % SPONSOR_REWARD
	else:
		_lbl_result.text = "DEFEAT"
		_lbl_result.add_theme_color_override("font_color", COLOR_ENEMY)
		_lbl_contract.text = "CONTRACT FAILED"
		GameState.credits -= SPONSOR_PENALTY
		_lbl_reward.text = "-%d CREDITS" % SPONSOR_PENALTY
	GameState.save_game()


func _on_return_to_base() -> void:
	get_tree().change_scene_to_file("res://scenes/Management.tscn")
