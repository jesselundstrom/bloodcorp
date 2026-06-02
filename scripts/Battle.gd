extends Control

const InjuryData = preload("res://scripts/InjuryData.gd")
const BattleIsoTileScene := preload("res://scripts/BattleIsoTile.gd")
const BattleUnitVisualScene := preload("res://scripts/BattleUnitVisual.gd")
const BattleCombatEffectScene := preload("res://scripts/BattleCombatEffect.gd")


const ENEMY_NAMES := [
	"GRAK", "VOSS", "ZARETH", "NAXIS", "KRUL", "THANE", "OREX", "VELD",
	"CRUX", "MORD", "SLASH", "BONE", "WREX", "DRAK", "TYKE", "SORN",
	"KAEL", "RAZE", "FLUX", "TOMB", "VEX", "GORN", "BLUD", "KRIX"
]

# Sponsor data is read from GameState.active_sponsor at _ready.

const GRID_COLS := 9
const GRID_ROWS := 6
const UNIT_SIZE := Vector2(56, 56)
const MOVE_TILE_SIZE := Vector2(42, 28)
const RING_SIZE := Vector2(52, 30)
const DEFAULT_MOVE_RANGE := 3
const DEFAULT_ATTACK_RANGE := 1
const MOVE_STEP_DURATION := 0.12
const ATTACK_LUNGE_DURATION := 0.08

# Sprite sheet: 1536x1024, 3 columns x 2 rows of 512x512 frames
const SPRITE_SHEET_PATH := "res://assets/sprites/gladiators.png"
const SPRITE_FRAME_W := 512
const SPRITE_FRAME_H := 512
const SPRITE_COLS := 3
const SPRITE_ROWS := 2
const ANIMATED_SHEET_PATHS := {
	"brutal_charge": "res://assets/sprites/gladiators/brutal_charge.png",
	"marksman": "res://assets/sprites/gladiators/marksman.png",
	"execution_mark": "res://assets/sprites/gladiators/execution_mark.png",
	"shield_bash": "res://assets/sprites/gladiators/shield_bash.png",
	"enemy_bruiser": "res://assets/sprites/gladiators/enemy_bruiser.png",
}

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
const COLOR_OBSTACLE := Color(0.10, 0.08, 0.06, 0.68)
const COLOR_OBSTACLE_BORDER := Color(0.55, 0.38, 0.0, 0.45)
const COLOR_HAZARD := Color(1.0, 0.133, 0.267, 0.22)
const COLOR_HAZARD_BORDER := Color(1.0, 0.667, 0.0, 0.9)
const COLOR_CHARGE := Color(1.0, 0.55, 0.0, 1.0)
const COLOR_MARK := Color(0.8, 0.0, 1.0, 1.0)
const PROFICIENCY_BONUS := 2  # recruit tier; +3 veteran / +4 champion once rank field lands
const _DEFAULT_SKILL_BY_INDEX: Array = ["brutal_charge", "marksman", "execution_mark", "shield_bash"]
const MELEE_DAMAGE_DIE := 6   # 1d6 placeholder until weapon system
const RANGED_DAMAGE_DIE := 8  # 1d8 placeholder for Marksman
const SHOVE_IMPACT_DAMAGE := 2

const ARENA_LAYOUTS: Array = [
	{
		"name": "FURNACE RUN",
		"blockers": [Vector2i(3, 1), Vector2i(5, 1), Vector2i(4, 4)],
		"hazards": [Vector2i(4, 2), Vector2i(4, 3), Vector2i(2, 3), Vector2i(6, 2)],
		"player_spawns": [
			Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 1), Vector2i(1, 4), Vector2i(0, 1),
			Vector2i(0, 4), Vector2i(1, 2), Vector2i(1, 3), Vector2i(0, 0)
		],
		"enemy_spawns": [Vector2i(8, 2), Vector2i(8, 3), Vector2i(7, 1), Vector2i(7, 4), Vector2i(8, 1)],
	},
	{
		"name": "BROKEN PILLARS",
		"blockers": [Vector2i(3, 1), Vector2i(5, 1), Vector2i(4, 3), Vector2i(2, 4), Vector2i(6, 4)],
		"hazards": [Vector2i(4, 2), Vector2i(3, 3), Vector2i(5, 3)],
		"player_spawns": [
			Vector2i(0, 1), Vector2i(0, 4), Vector2i(1, 2), Vector2i(1, 3), Vector2i(0, 2),
			Vector2i(0, 3), Vector2i(1, 0), Vector2i(1, 5), Vector2i(0, 0)
		],
		"enemy_spawns": [Vector2i(8, 1), Vector2i(8, 4), Vector2i(7, 2), Vector2i(7, 3), Vector2i(8, 3)],
	},
	{
		"name": "BLOOD CHANNELS",
		"blockers": [Vector2i(4, 0), Vector2i(4, 5), Vector2i(2, 2), Vector2i(6, 3)],
		"hazards": [Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(3, 3), Vector2i(4, 3), Vector2i(5, 3)],
		"player_spawns": [
			Vector2i(0, 2), Vector2i(0, 3), Vector2i(1, 1), Vector2i(1, 4), Vector2i(0, 1),
			Vector2i(0, 4), Vector2i(1, 2), Vector2i(1, 3), Vector2i(0, 0)
		],
		"enemy_spawns": [Vector2i(8, 2), Vector2i(8, 3), Vector2i(7, 1), Vector2i(7, 4), Vector2i(8, 4)],
	},
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
var _animated_sheets: Dictionary = {}
var _combat_log: RichTextLabel = null
var _kills: int = 0
var _mark_killed: bool = false
var _downed_player_indices: Array = []
var _sponsor: Dictionary = {}
var _marked_unit = null
var _style_score: int = 0
var _selected_layout: Dictionary = {}
var _is_animating: bool = false

@onready var _arena: Control = $Layout/MainRow/Arena
@onready var _player_list: VBoxContainer = $Layout/MainRow/PlayerHPPanel/PlayerList
@onready var _enemy_list: VBoxContainer = $Layout/MainRow/EnemyHPPanel/EnemyList
@onready var _lbl_round: Label = $Layout/TopBar/HBox/LblRound
@onready var _lbl_objective: Label = $Layout/TopBar/HBox/LblObjective
@onready var _lbl_turn: Label = $Layout/TopBar/HBox/LblTurn
@onready var _lbl_unit_info: Label = $Layout/BottomBar/HBox/LblUnitInfo
@onready var _btn_attack: Button = $Layout/BottomBar/HBox/BtnAttack
@onready var _btn_bonus: Button = $Layout/BottomBar/HBox/BtnBonus
@onready var _bonus_popup: PopupMenu = $Layout/BottomBar/HBox/BtnBonus/BonusPopup
@onready var _btn_charge: Button = $Layout/BottomBar/HBox/BtnCharge
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
	_load_animated_sheets()
	_select_arena_layout()
	_apply_styles()
	_build_units()
	_sort_initiative()
	await get_tree().process_frame
	await get_tree().process_frame
	_draw_arena_floor()
	_draw_obstacles()
	_place_units()
	_build_combat_log()
	_log("[color=#ffaa00]ARENA: %s[/color]" % _selected_layout.get("name", "UNKNOWN"))
	_build_hp_bars()
	_btn_attack.pressed.connect(_on_attack)
	_btn_bonus.pressed.connect(_on_bonus_pressed)
	_bonus_popup.id_pressed.connect(_on_bonus_popup_id_pressed)
	_btn_charge.pressed.connect(_on_charge)
	_btn_pass.pressed.connect(_on_pass)
	_btn_return_base.pressed.connect(_on_return_to_base)
	_update_objective_label()
	_start_turn()


func _load_animated_sheets() -> void:
	_animated_sheets.clear()
	for archetype: String in ANIMATED_SHEET_PATHS.keys():
		var path: String = ANIMATED_SHEET_PATHS[archetype]
		if not ResourceLoader.exists(path):
			continue
		var texture := load(path) as Texture2D
		if texture != null:
			_animated_sheets[archetype] = texture


func _select_arena_layout() -> void:
	_selected_layout = ARENA_LAYOUTS.pick_random()


func _layout_positions(key: String) -> Array:
	if _selected_layout.is_empty():
		return []
	return _selected_layout.get(key, [])


func _is_blocker(pos: Vector2i) -> bool:
	return _layout_positions("blockers").has(pos)


func _is_hazard(pos: Vector2i) -> bool:
	return _layout_positions("hazards").has(pos)


func _is_walkable(pos: Vector2i, ignored_unit = null) -> bool:
	return _is_in_grid(pos) and not _is_blocker(pos) and not _is_tile_occupied(pos, ignored_unit)


func _draw_obstacles() -> void:
	for pos: Vector2i in _layout_positions("hazards"):
		_draw_terrain_tile(pos, COLOR_HAZARD, COLOR_HAZARD_BORDER, BattleIsoTile.VARIANT_HAZARD)
	for pos: Vector2i in _layout_positions("blockers"):
		_draw_terrain_tile(pos, COLOR_OBSTACLE, COLOR_OBSTACLE_BORDER, BattleIsoTile.VARIANT_BLOCKER)


func _draw_terrain_tile(pos: Vector2i, fill_color: Color, border_color: Color, variant := BattleIsoTile.VARIANT_MOVE) -> void:
	var tile := _create_iso_tile_visual(pos, fill_color, border_color, MOVE_TILE_SIZE, variant)
	tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_arena.add_child(tile)


func _create_iso_tile_visual(pos: Vector2i, fill_color: Color, border_color: Color, size := MOVE_TILE_SIZE, variant := BattleIsoTile.VARIANT_MOVE) -> BattleIsoTile:
	var tile := BattleIsoTileScene.new() as BattleIsoTile
	tile.size = size
	tile.custom_minimum_size = size
	tile.position = _iso_to_screen(pos) + (UNIT_SIZE - size) * 0.5
	tile.z_index = 2
	tile.setup(fill_color, border_color, 2.0, variant)
	return tile


func _draw_arena_floor() -> void:
	# Use an ArenaFloor Control subclass drawn via shader on ArenaBg
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

	if not _arena.has_node("ArenaScanlines"):
		var scanlines := ColorRect.new()
		scanlines.name = "ArenaScanlines"
		scanlines.set_anchors_preset(Control.PRESET_FULL_RECT)
		scanlines.mouse_filter = Control.MOUSE_FILTER_IGNORE
		scanlines.z_index = 1
		var scan_shader := load("res://assets/shaders/scanlines.gdshader") as Shader
		if scan_shader:
			var scan_mat := ShaderMaterial.new()
			scan_mat.shader = scan_shader
			scan_mat.set_shader_parameter("opacity", 0.035)
			scanlines.material = scan_mat
		_arena.add_child(scanlines)


func _build_combat_log() -> void:
	_combat_log = RichTextLabel.new()
	_combat_log.bbcode_enabled = true
	_combat_log.scroll_following = true
	_combat_log.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_combat_log.focus_mode = Control.FOCUS_NONE

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
	_combat_log.add_theme_font_size_override("normal_font_size", UITheme.SIZE_XXS)

	_arena.add_child(_combat_log)


func _log(msg: String) -> void:
	if _combat_log:
		_combat_log.append_text(msg + "\n")


func _apply_styles() -> void:
	$Layout/TopBar/HBox.add_theme_constant_override("separation", 8)
	$Layout/BottomBar/HBox.add_theme_constant_override("separation", 6)
	_lbl_unit_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_lbl_unit_info.clip_text = true
	_lbl_unit_info.custom_minimum_size = Vector2(520, 52)
	for btn: Button in [_btn_attack, _btn_bonus, _btn_charge, _btn_pass]:
		btn.custom_minimum_size = Vector2(104, 56)
	_btn_pass.tooltip_text = "End the active unit's turn."

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
		lbl.add_theme_font_size_override("font_size", UITheme.SIZE_SM)

	# Top bar: player team name cyan, enemy team red, objective amber centre
	_lbl_round.text = "IRON LEGION"
	_lbl_round.add_theme_color_override("font_color", COLOR_PLAYER)
	_lbl_round.add_theme_font_size_override("font_size", UITheme.SIZE_XS)

	_lbl_turn.text = "CRIMSON VIPERS"
	_lbl_turn.add_theme_color_override("font_color", COLOR_ENEMY)
	_lbl_turn.add_theme_font_size_override("font_size", UITheme.SIZE_XS)

	$Layout/TopBar/HBox/LblObjective.add_theme_color_override("font_color", Color(1.0, 0.667, 0.0, 1.0))
	$Layout/TopBar/HBox/LblObjective.add_theme_font_size_override("font_size", UITheme.SIZE_XS)

	_style_button(_btn_attack)
	_style_button(_btn_bonus)
	_style_charge_button()
	_style_button(_btn_pass)
	_style_button(_btn_return_base)

	$ResultOverlay/VBox.add_theme_constant_override("separation", 14)
	for lbl: Label in [_lbl_result, _lbl_contract, _lbl_reward]:
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_btn_return_base.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	_lbl_result.add_theme_font_size_override("font_size", UITheme.SIZE_HERO)
	_lbl_result.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_lbl_contract.add_theme_font_size_override("font_size", UITheme.SIZE_XL)
	_lbl_contract.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95, 1.0))
	_lbl_reward.add_theme_font_size_override("font_size", UITheme.SIZE_LG)
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
	btn.add_theme_font_size_override("font_size", UITheme.SIZE_SM)


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
	_btn_charge.add_theme_font_size_override("font_size", UITheme.SIZE_SM)



func _stat_mod(score: int) -> int:
	return floori((score - 10) / 2.0)


func _roll_die(sides: int) -> int:
	return randi_range(1, sides)


func _roll_d20(advantage: bool) -> int:
	var r1 := _roll_die(20)
	if not advantage:
		return r1
	return maxi(r1, _roll_die(20))


func _attack_stat_mod(attacker: Dictionary) -> int:
	if int(attacker.get("attack_range", DEFAULT_ATTACK_RANGE)) > 1:
		return _stat_mod(int(attacker.get("dexterity", 10)))
	return _stat_mod(int(attacker.get("strength_score", 10)))


func _attack_bonus(attacker: Dictionary) -> int:
	return _attack_stat_mod(attacker) + PROFICIENCY_BONUS


func _damage_die(attacker: Dictionary) -> int:
	return RANGED_DAMAGE_DIE if int(attacker.get("attack_range", DEFAULT_ATTACK_RANGE)) > 1 else MELEE_DAMAGE_DIE


func _resolve_attack(attacker: Dictionary, target: Dictionary, attacker_color: String) -> bool:
	var advantage: bool = _is_flanked(attacker, target) or (target == _marked_unit)
	var nat := _roll_d20(advantage)
	var total := nat + _attack_bonus(attacker)
	var dc := int(target.get("defense_class", 10))
	var target_color := "[color=#00ffcc]" if target["team"] == "player" else "[color=#ff2244]"
	var adv_tag := "  [color=#ffaa00][ADV][/color]" if advantage else ""

	if total < dc:
		_log("%s%s[/color] missed %s%s[/color]  [color=#888888](%d vs DC %d)[/color]%s" % [
			attacker_color, attacker["name"], target_color, target["name"], total, dc, adv_tag
		])
		await _play_attack_feedback(attacker, target, false, 0, false)
		return false

	var is_crit := nat == 20
	var die := _damage_die(attacker)
	var dice_count := 2 if is_crit else 1
	var dmg := 0
	for _i in range(dice_count):
		dmg += _roll_die(die)
	dmg += _attack_stat_mod(attacker)
	dmg = maxi(1, dmg)

	var crit_tag := "  [color=#ff2244][CRIT!][/color]" if is_crit else ""
	_log("%s%s[/color] hit %s%s[/color] for [color=#ffaa00]%d[/color] dmg  [color=#888888](%d vs DC %d)[/color]%s%s" % [
		attacker_color, attacker["name"], target_color, target["name"],
		dmg, total, dc, adv_tag, crit_tag
	])
	await _play_attack_feedback(attacker, target, true, dmg, is_crit)
	return await _apply_damage(target, dmg, false)


func _spawn_position(key: String, index: int, fallback: Vector2i) -> Vector2i:
	var spawns := _layout_positions(key)
	if index >= 0 and index < spawns.size():
		return spawns[index]
	return fallback


func _build_units() -> void:
	for i in range(GameState.roster.size()):
		var g: Dictionary = GameState.roster[i].duplicate()
		g["team"] = "player"
		g["is_mark"] = false
		g["roster_index"] = i
		g["grid_pos"] = _spawn_position("player_spawns", i, Vector2i(i % 2, floori(i / 2.0)))
		# Apply injury stat penalties before deriving mods.
		var hp_pct_pen: float = 0.0
		for inj in g.get("injuries", []):
			var inj_data: Dictionary = InjuryData.INJURIES.get(inj["key"], {})
			for stat_key in inj_data.get("stat_penalties", {}).keys():
				g[stat_key] = int(g.get(stat_key, 10)) + int(inj_data["stat_penalties"][stat_key])
			hp_pct_pen += float(inj_data.get("hp_pct_penalty", 0.0))
		var con_mod: int = _stat_mod(int(g.get("constitution", 10)))
		var dex_mod: int = _stat_mod(int(g.get("dexterity", 10)))
		g["hp_max"] = maxi(1, int(round((8 + con_mod) * (1.0 - hp_pct_pen))))
		g["defense_class"] = 10 + dex_mod + int(g.get("armor", 0))
		g["hp_current"] = g["hp_max"]
		g["sprite_col"] = i % (SPRITE_COLS * SPRITE_ROWS)
		g["visual_archetype"] = _DEFAULT_SKILL_BY_INDEX[i] if i < _DEFAULT_SKILL_BY_INDEX.size() else "brutal_charge"
		g["visual_root"] = null
		g["rect_node"] = null
		g["sprite_node"] = null
		g["ring_node"] = null
		g["shadow_node"] = null
		g["status_node"] = null
		g["hp_bar_node"] = null
		g["hp_row_node"] = null
		g["hp_name_node"] = null
		var skill_key: String = String(g.get("skill", ""))
		if skill_key == "" and i < _DEFAULT_SKILL_BY_INDEX.size():
			skill_key = _DEFAULT_SKILL_BY_INDEX[i]
		g["skill"] = skill_key
		if skill_key != "":
			g["visual_archetype"] = skill_key
		if skill_key != "" and SkillData.SKILLS.has(skill_key):
			var sk: Dictionary = SkillData.SKILLS[skill_key]
			if int(sk.get("attack_range", 1)) > 1:
				g["attack_range"] = int(sk["attack_range"])
		_add_combat_state(g)
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
			"strength_score": randi_range(8, 18),
			"dexterity": randi_range(8, 18),
			"constitution": randi_range(8, 18),
			"intelligence": randi_range(8, 18),
			"charisma": randi_range(8, 18),
			"team": "enemy",
			"is_mark": mark_name != "" and name_pool[i] == mark_name,
			"grid_pos": _spawn_position("enemy_spawns", i, Vector2i(GRID_COLS - 1 - (i % 2), floori(i / 2.0))),
			"hp_max": 0,
			"hp_current": 0,
			"defense_class": 0,
			"sprite_col": i % (SPRITE_COLS * SPRITE_ROWS),
			"visual_archetype": "enemy_bruiser",
			"visual_root": null,
			"rect_node": null,
			"sprite_node": null,
			"ring_node": null,
			"shadow_node": null,
			"status_node": null,
			"hp_bar_node": null,
			"hp_row_node": null,
			"hp_name_node": null,
		}
		var e_con_mod: int = _stat_mod(int(e["constitution"]))
		var e_dex_mod: int = _stat_mod(int(e["dexterity"]))
		e["hp_max"] = 8 + e_con_mod
		e["defense_class"] = 10 + e_dex_mod + int(e["armor"])
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


func _grid_neighbors(pos: Vector2i) -> Array:
	return [
		pos + Vector2i(1, 0),
		pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),
		pos + Vector2i(0, -1),
	]


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
	var frontier: Array = [origin]
	var distances: Dictionary = {origin: 0}
	var cursor := 0
	while cursor < frontier.size():
		var current: Vector2i = frontier[cursor]
		cursor += 1
		var current_distance: int = distances[current]
		if current_distance >= move_range:
			continue
		for next: Vector2i in _grid_neighbors(current):
			if distances.has(next) or not _is_walkable(next, unit):
				continue
			distances[next] = current_distance + 1
			frontier.append(next)
			result.append(next)
	return result


func _set_unit_screen_position(unit: Dictionary) -> void:
	var visual := unit.get("visual_root", null) as Control
	if visual != null:
		visual.position = _iso_to_screen(unit["grid_pos"])
		return
	if unit.get("rect_node", null) == null:
		return
	var rect := unit["rect_node"] as Control
	rect.position = _iso_to_screen(unit["grid_pos"])
	_set_unit_ring_position(unit)


func _set_unit_ring_position(unit: Dictionary) -> void:
	if unit.get("visual_root", null) != null:
		return
	if unit.get("ring_node", null) == null:
		return
	var ring := unit["ring_node"] as Control
	ring.position = _iso_to_screen(unit["grid_pos"]) + Vector2(
		(UNIT_SIZE.x - RING_SIZE.x) * 0.5,
		UNIT_SIZE.y - RING_SIZE.y * 0.72
	)


func _find_path(unit: Dictionary, destination: Vector2i) -> Array:
	var origin: Vector2i = unit.get("grid_pos", Vector2i(-1, -1))
	if origin == destination:
		return []
	if not _is_walkable(destination, unit):
		return []

	var frontier: Array = [origin]
	var parents: Dictionary = {origin: Vector2i(-999, -999)}
	var cursor := 0
	while cursor < frontier.size():
		var current: Vector2i = frontier[cursor]
		cursor += 1
		if current == destination:
			break
		for next: Vector2i in _grid_neighbors(current):
			if parents.has(next) or not _is_walkable(next, unit):
				continue
			parents[next] = current
			frontier.append(next)

	if not parents.has(destination):
		return []

	var path: Array = []
	var step := destination
	while step != origin:
		path.push_front(step)
		step = parents[step]
	return path


func _set_animating(animating: bool) -> void:
	_is_animating = animating
	if animating:
		_btn_attack.disabled = true
		_btn_bonus.disabled = true
		_btn_charge.disabled = true
		_btn_pass.disabled = true
	else:
		_update_pass_button_state()


func _update_pass_button_state() -> void:
	_btn_pass.disabled = _is_animating or _battle_over or _initiative.is_empty() or not _is_player_turn()


func _move_unit_to(unit: Dictionary, grid_pos: Vector2i, animate := true) -> void:
	if unit.is_empty():
		return
	var visual := unit.get("visual_root", null) as BattleUnitVisual
	if visual == null and unit.get("rect_node", null) == null:
		unit["grid_pos"] = grid_pos
		return

	var path := _find_path(unit, grid_pos)
	if path.is_empty():
		unit["grid_pos"] = grid_pos
		_set_unit_screen_position(unit)
		return

	var mover := unit["rect_node"] as Control
	if visual != null:
		mover = visual
	var ring := unit.get("ring_node", null) as Control
	if not animate:
		unit["grid_pos"] = grid_pos
		_set_unit_screen_position(unit)
		return

	_set_animating(true)
	for step: Vector2i in path:
		var previous_pos: Vector2i = unit["grid_pos"]
		unit["grid_pos"] = step
		if visual != null:
			visual.set_facing(step - previous_pos)
			visual.play("walk")
		var target_pos := _iso_to_screen(step)
		var ring_pos := target_pos + Vector2((UNIT_SIZE.x - RING_SIZE.x) * 0.5, UNIT_SIZE.y - RING_SIZE.y * 0.72)
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(mover, "position", target_pos + Vector2(0, -4), MOVE_STEP_DURATION * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(mover, "scale", Vector2(1.05, 0.96), MOVE_STEP_DURATION * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		if ring and visual == null:
			tween.tween_property(ring, "position", ring_pos, MOVE_STEP_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished

		tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(mover, "position", target_pos, MOVE_STEP_DURATION * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(mover, "scale", Vector2.ONE, MOVE_STEP_DURATION * 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
	if visual != null:
		visual.play("idle")
	_set_unit_screen_position(unit)
	_set_animating(false)


func _make_unit_texture(sprite_index: int) -> AtlasTexture:
	var col := sprite_index % SPRITE_COLS
	var row := floori(sprite_index / float(SPRITE_COLS)) % SPRITE_ROWS
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
		var visual := BattleUnitVisualScene.new() as BattleUnitVisual
		visual.setup(UNIT_SIZE, RING_SIZE)
		visual.position = _iso_to_screen(unit["grid_pos"])
		visual.z_index = 10
		visual.mouse_default_cursor_shape = Control.CURSOR_ARROW
		visual.gui_input.connect(_on_unit_gui_input.bind(unit))
		visual.mouse_entered.connect(_on_unit_mouse_entered.bind(unit))
		visual.mouse_exited.connect(_on_unit_mouse_exited.bind(unit))

		var fallback_texture: Texture2D = _make_unit_texture(unit["sprite_col"]) if _sprite_sheet else null
		var archetype := String(unit.get("visual_archetype", "enemy_bruiser"))
		visual.set_texture_source(_animated_sheets.get(archetype, null), fallback_texture)
		_arena.add_child(visual)

		unit["visual_root"] = visual
		unit["rect_node"] = visual.sprite_node
		unit["sprite_node"] = visual.sprite_node
		unit["ring_node"] = visual.ring_node
		unit["shadow_node"] = visual.shadow_node
		unit["status_node"] = visual.status_node


func _show_move_tiles(unit: Dictionary) -> void:
	_clear_move_tiles()
	if _is_animating or not _is_player_turn() or bool(unit.get("has_moved", false)):
		return

	for grid_pos: Vector2i in _get_reachable_tiles(unit):
		var tile := _create_iso_tile_visual(grid_pos, COLOR_MOVE_TILE, Color(0.0, 1.0, 0.8, 0.48), MOVE_TILE_SIZE, BattleIsoTile.VARIANT_MOVE)
		tile.mouse_filter = Control.MOUSE_FILTER_STOP
		tile.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		tile.z_index = 4
		tile.gui_input.connect(_on_move_tile_gui_input.bind(grid_pos))
		tile.mouse_entered.connect(_on_move_tile_mouse_entered.bind(tile))
		tile.mouse_exited.connect(_on_move_tile_mouse_exited.bind(tile))
		_arena.add_child(tile)
		_move_tiles.append(tile)


func _clear_move_tiles() -> void:
	for tile: Control in _move_tiles:
		if is_instance_valid(tile):
			tile.queue_free()
	_move_tiles.clear()


func _show_attack_range_tiles(unit: Dictionary) -> void:
	_clear_attack_range_tiles()
	var atk_range: int = int(unit.get("attack_range", DEFAULT_ATTACK_RANGE))
	if _is_animating or atk_range <= 1 or not _is_player_turn():
		return
	for u: Dictionary in _units:
		if u["team"] != "enemy" or int(u.get("hp_current", 0)) <= 0:
			continue
		if _grid_distance(unit["grid_pos"], u["grid_pos"]) > atk_range:
			continue
		var tile := _create_iso_tile_visual(u["grid_pos"], Color(1.0, 0.133, 0.267, 0.16), Color(1.0, 0.133, 0.267, 0.42), MOVE_TILE_SIZE, BattleIsoTile.VARIANT_ATTACK)
		tile.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.z_index = 3
		_arena.add_child(tile)
		_attack_range_tiles.append(tile)


func _clear_attack_range_tiles() -> void:
	for tile: Control in _attack_range_tiles:
		if is_instance_valid(tile):
			tile.queue_free()
	_attack_range_tiles.clear()


func _is_reachable_tile(unit: Dictionary, grid_pos: Vector2i) -> bool:
	return _get_reachable_tiles(unit).has(grid_pos)


func _on_move_tile_gui_input(event: InputEvent, grid_pos: Vector2i) -> void:
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return
	if _is_animating or not _is_player_turn():
		return

	var unit := _get_active_unit()
	if unit.is_empty() or not _is_reachable_tile(unit, grid_pos):
		return

	unit["has_moved"] = true
	_log("[color=#00ffcc]%s[/color] repositioned" % unit["name"])
	_clear_move_tiles()
	_clear_target_selection(false)
	await _move_unit_to(unit, grid_pos)
	_update_unit_info(unit)
	_update_targeting_enabled()
	_update_attack_button_state()
	_update_bonus_button_state()
	_update_charge_button_state()
	_show_attack_range_tiles(unit)
	_highlight_active(unit)
	accept_event()


func _on_move_tile_mouse_entered(tile: BattleIsoTile) -> void:
	tile.setup(COLOR_MOVE_TILE_HOVER, Color(1.0, 1.0, 1.0, 0.7), 2.0, BattleIsoTile.VARIANT_MOVE)


func _on_move_tile_mouse_exited(tile: BattleIsoTile) -> void:
	tile.setup(COLOR_MOVE_TILE, Color(0.0, 1.0, 0.8, 0.48), 2.0, BattleIsoTile.VARIANT_MOVE)


func _build_hp_bars() -> void:
	for unit: Dictionary in _units:
		var row := PanelContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.custom_minimum_size = Vector2(132, 36)

		var container := VBoxContainer.new()
		container.add_theme_constant_override("separation", 2)
		row.add_child(container)

		var name_lbl := Label.new()
		name_lbl.text = unit["name"]
		name_lbl.add_theme_font_size_override("font_size", UITheme.SIZE_XXS)
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
		unit["hp_row_node"] = row
		unit["hp_name_node"] = name_lbl
		_style_hp_row(unit, false)

		if unit["team"] == "player":
			_player_list.add_child(row)
		else:
			_enemy_list.add_child(row)


func _style_hp_row(unit: Dictionary, active := false) -> void:
	var row := unit.get("hp_row_node", null) as PanelContainer
	var bar := unit.get("hp_bar_node", null) as ProgressBar
	var name_lbl := unit.get("hp_name_node", null) as Label
	if row == null or bar == null or name_lbl == null:
		return

	var team_color: Color = COLOR_PLAYER if unit["team"] == "player" else COLOR_ENEMY
	var hp_pct := float(unit.get("hp_current", 0)) / maxf(1.0, float(unit.get("hp_max", 1)))
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 0.22) if active else Color(0, 0, 0, 0)
	panel_style.border_color = team_color if active else Color(0, 0, 0, 0)
	panel_style.set_border_width_all(1 if active else 0)
	row.add_theme_stylebox_override("panel", panel_style)

	var fill := StyleBoxFlat.new()
	if hp_pct <= 0.33:
		fill.bg_color = COLOR_ENEMY
	elif hp_pct <= 0.66:
		fill.bg_color = Color(1.0, 0.667, 0.0, 1.0)
	else:
		fill.bg_color = team_color
	bar.add_theme_stylebox_override("fill", fill)

	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.18, 0.18, 0.22, 0.92)
	bar.add_theme_stylebox_override("background", bg)
	name_lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1) if active else team_color)


func _update_hp_row_visuals(active_unit: Dictionary) -> void:
	for unit: Dictionary in _units:
		_style_hp_row(unit, unit == active_unit)


func _update_objective_label() -> void:
	var sponsor_name: String = _sponsor.get("name", "SPONSOR")
	var style_tag := "  STYLE: %d" % _style_score if _style_score > 0 else ""
	match _sponsor.get("type", "kills"):
		"style":
			var req_rounds: int = int(_sponsor.get("requirement_rounds", 1))
			_lbl_objective.text = "ROUND %d  |  %s: WIN IN ≤ %d ROUNDS%s" % [
				_round, sponsor_name, req_rounds, style_tag
			]
		"target":
			var target_name: String = _sponsor.get("requirement_target", "?")
			var status: String = "ELIMINATED" if _mark_killed else "ALIVE"
			_lbl_objective.text = "ROUND %d  |  %s: EXECUTE %s  [%s]%s" % [
				_round, sponsor_name, target_name, status, style_tag
			]
		_:
			var req: int = int(_sponsor.get("requirement_kills", 0))
			_lbl_objective.text = "ROUND %d  |  %s: KILL %d  [%d/%d]%s" % [
				_round, sponsor_name, req, _kills, req, style_tag
			]


func _update_unit_info(unit: Dictionary) -> void:
	var move_state := "USED" if bool(unit.get("has_moved", false)) else "READY"
	var action_state := "READY" if bool(unit.get("has_main_action", true)) else "USED"
	var bonus_state := "BONUS" if bool(unit.get("has_bonus_action", true)) else "USED"
	var skill_part := ""
	var skill_key := String(unit.get("skill", ""))
	if skill_key != "" and SkillData.SKILLS.has(skill_key):
		var sk: Dictionary = SkillData.SKILLS[skill_key]
		var display: String = sk.get("display_name", skill_key.to_upper())
		match sk.get("action_cost", ""):
			"main":
				var ready := bool(unit.get("has_main_action", true)) and not bool(unit.get("has_moved", false))
				skill_part = "  SKILL[ACTION]: %s" % (display.to_upper() if ready else "USED")
			"passive":
				var atk_ready := bool(unit.get("has_main_action", true))
				skill_part = "  SKILL[PASSIVE]: %s%s" % [display.to_upper(), "" if atk_ready else " (ACTION USED)"]
			"bonus":
				var bonus_ready := bool(unit.get("has_bonus_action", true))
				skill_part = "  SKILL[BONUS]: %s (%s)" % [display.to_upper(), "READY" if bonus_ready else "USED"]
	var skill_line := skill_part.strip_edges()
	if skill_line == "":
		skill_line = "SKILL: NONE"
	_lbl_unit_info.text = "%s  |  HP %d/%d  STR %d  SPD %d  ARM %d\nMOVE %s  |  ACTION %s  |  BONUS %s  |  %s" % [
		unit["name"],
		unit["hp_current"], unit["hp_max"],
		unit["strength"], unit["speed"], unit["armor"],
		move_state, action_state, bonus_state, skill_line
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
	_update_pass_button_state()
	_update_targeting_enabled()
	_update_attack_button_state()
	_update_bonus_button_state()
	_update_charge_button_state()
	if is_player_turn:
		_show_move_tiles(unit)
		_show_attack_range_tiles(unit)

	if not is_player_turn:
		await get_tree().create_timer(0.6).timeout
		await _enemy_act(unit)


func _highlight_active(active_unit: Dictionary) -> void:
	for unit: Dictionary in _units:
		if unit.get("visual_root", null) == null and unit["rect_node"] == null:
			continue
		_update_unit_visual(unit, active_unit)
	_update_hp_row_visuals(active_unit)


func _update_unit_visual(unit: Dictionary, active_unit: Dictionary) -> void:
	var visual := unit.get("visual_root", null) as BattleUnitVisual
	if visual != null:
		var hp_max := maxf(1.0, float(unit.get("hp_max", 1)))
		visual.set_state({
			"active": unit == active_unit,
			"selected": unit == _selected_target and _is_valid_target(unit),
			"hovered": unit == _hovered_target,
			"targetable": _is_targetable(unit),
			"sponsor_mark": unit.get("is_mark", false) and int(unit.get("hp_current", 0)) > 0,
			"execution_mark": unit == _marked_unit and int(unit.get("hp_current", 0)) > 0,
			"low_hp": float(unit.get("hp_current", 0)) / hp_max <= 0.35,
			"team": unit.get("team", ""),
		})
		return

	var tex_rect := unit["rect_node"] as TextureRect
	if unit == _hovered_target and _is_targetable(unit):
		tex_rect.modulate = Color(1.3, 1.3, 1.3, 1.0)
	else:
		tex_rect.modulate = Color(1, 1, 1, 1)

	var ring = unit.get("ring_node", null)
	if ring == null:
		return
	if unit == _selected_target and _is_valid_target(unit):
		ring.setup(COLOR_SELECTED_BORDER, 3.0)
	elif unit == _hovered_target and _is_targetable(unit):
		ring.setup(COLOR_HOVER_BORDER, 2.0)
	elif unit == active_unit:
		ring.setup(COLOR_ACTIVE_BORDER, 2.0)
	elif unit.get("is_mark", false) and int(unit.get("hp_current", 0)) > 0:
		ring.setup(Color(1.0, 0.667, 0.0, 0.9), 2.0)
	elif unit == _marked_unit and int(unit.get("hp_current", 0)) > 0:
		ring.setup(COLOR_MARK, 2.0)
	else:
		ring.setup(COLOR_TRANSPARENT, 0.0)


func _is_player_turn() -> bool:
	if _battle_over or _initiative.is_empty():
		return false
	return str(_initiative[_turn_index]["team"]) == "player"


func _is_targetable(unit: Dictionary) -> bool:
	if _is_animating or not _is_player_turn() or str(unit["team"]) != "enemy" or int(unit["hp_current"]) <= 0:
		return false
	var active := _get_active_unit()
	return not active.is_empty() and bool(active.get("has_main_action", true)) and _is_in_attack_range(active, unit)


func _is_valid_target(target) -> bool:
	if _is_animating:
		return false
	if not (target is Dictionary):
		return false
	if not _units.has(target) or str(target.get("team", "")) != "enemy" or int(target.get("hp_current", 0)) <= 0:
		return false
	var active := _get_active_unit()
	return not active.is_empty() and bool(active.get("has_main_action", true)) and _is_in_attack_range(active, target)


func _update_targeting_enabled() -> void:
	for unit: Dictionary in _units:
		var targetable: bool = not _is_animating and _is_targetable(unit)
		var visual := unit.get("visual_root", null) as Control
		if visual != null:
			visual.mouse_filter = Control.MOUSE_FILTER_STOP if targetable else Control.MOUSE_FILTER_IGNORE
			visual.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if targetable else Control.CURSOR_ARROW
			continue
		if unit["rect_node"] == null:
			continue
		var rect := unit["rect_node"] as Control
		rect.mouse_filter = Control.MOUSE_FILTER_STOP if targetable else Control.MOUSE_FILTER_IGNORE
		rect.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if targetable else Control.CURSOR_ARROW


func _update_attack_button_state() -> void:
	if _is_animating:
		_btn_attack.disabled = true
		_btn_attack.text = "WAIT"
		_btn_attack.tooltip_text = "Animation in progress"
		_style_attack_button(false)
		return
	if _battle_over or _initiative.is_empty():
		_btn_attack.disabled = true
		_btn_attack.text = "ATTACK"
		_btn_attack.tooltip_text = ""
		_style_attack_button(false)
		return

	var active := _get_active_unit()
	var has_action: bool = active.is_empty() or bool(active.get("has_main_action", true))
	var has_target: bool = _is_valid_target(_selected_target)
	if _is_player_turn():
		_btn_attack.disabled = not has_target
		if not has_action:
			_btn_attack.text = "ACTION USED"
			_btn_attack.tooltip_text = "This unit has already used its main action."
		else:
			_btn_attack.text = "ATTACK" if has_target else "NO TARGET"
			_btn_attack.tooltip_text = "" if has_target else "Select an enemy in attack range."
		_style_attack_button(has_target)
	else:
		_btn_attack.disabled = true
		_btn_attack.text = "ATTACK"
		_btn_attack.tooltip_text = ""
		_style_attack_button(false)


func _get_adjacent_enemy(unit: Dictionary) -> Dictionary:
	for u: Dictionary in _units:
		if u["team"] == "enemy" and int(u.get("hp_current", 0)) > 0:
			if _grid_distance(unit["grid_pos"], u["grid_pos"]) == 1:
				return u
	return {}


func _available_bonus_actions(unit: Dictionary) -> Array:
	var out: Array = []
	var skill := String(unit.get("skill", ""))
	if skill != "" and SkillData.SKILLS.get(skill, {}).get("action_cost", "") == "bonus":
		out.append(skill)
	out.append("shove")
	return out


func _update_bonus_button_state() -> void:
	if _is_animating:
		_btn_bonus.disabled = true
		_btn_bonus.text = "WAIT"
		_btn_bonus.tooltip_text = "Animation in progress"
		return
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		_btn_bonus.disabled = true
		_btn_bonus.text = "BONUS"
		_btn_bonus.tooltip_text = ""
		return

	var active := _get_active_unit()
	if active.is_empty() or not bool(active.get("has_bonus_action", true)):
		_btn_bonus.disabled = true
		_btn_bonus.text = "BONUS USED"
		_btn_bonus.tooltip_text = "This unit has already used its bonus action."
		return

	var actions := _available_bonus_actions(active)
	var any_usable := false
	for action_key: String in actions:
		if action_key == "shove":
			if not _get_adjacent_enemy(active).is_empty():
				any_usable = true
				break
		elif action_key == "execution_mark":
			if not _get_mark_target(active).is_empty():
				any_usable = true
				break
		elif action_key == "shield_bash":
			if not _get_adjacent_enemy(active).is_empty():
				any_usable = true
				break
		else:
			any_usable = true
			break
	_btn_bonus.disabled = not any_usable
	_btn_bonus.text = "BONUS" if any_usable else "NO BONUS"
	_btn_bonus.tooltip_text = "" if any_usable else "No bonus action has a valid adjacent target."


func _on_bonus_pressed() -> void:
	if _is_animating or _battle_over or _initiative.is_empty() or not _is_player_turn():
		return
	var active := _get_active_unit()
	if active.is_empty() or not bool(active.get("has_bonus_action", true)):
		return

	var actions := _available_bonus_actions(active)
	_bonus_popup.clear()
	for i in range(actions.size()):
		var action_key: String = actions[i]
		var label: String
		if action_key == "shove":
			label = SkillData.SHOVE["display_name"]
			var has_target := not _get_adjacent_enemy(active).is_empty()
			if not has_target:
				label += " (NO TARGET)"
		else:
			label = SkillData.SKILLS.get(action_key, {}).get("display_name", action_key.to_upper())
			var valid_targets := String(SkillData.SKILLS.get(action_key, {}).get("valid_targets", ""))
			var targets_enemy: bool = valid_targets == "enemy"
			var targets_wounded: bool = valid_targets == "wounded_enemy"
			if targets_wounded and _get_mark_target(active).is_empty():
				label += " (NO TARGET)"
			elif targets_enemy and _get_adjacent_enemy(active).is_empty():
				label += " (NO TARGET)"
		_bonus_popup.add_item(label, i)
	_bonus_popup.popup(Rect2i(
		int(_btn_bonus.global_position.x),
		int(_btn_bonus.global_position.y) - 96,
		int(_btn_bonus.size.x), 0
	))


func _on_bonus_popup_id_pressed(id: int) -> void:
	if _is_animating:
		return
	var active := _get_active_unit()
	if active.is_empty():
		return
	var actions := _available_bonus_actions(active)
	if id < 0 or id >= actions.size():
		return
	match actions[id]:
		"shove":
			await _on_shove()
		"execution_mark":
			_on_mark()
		"shield_bash":
			await _on_shield_bash()


func _update_charge_button_state() -> void:
	if _is_animating:
		_btn_charge.disabled = true
		_btn_charge.visible = true
		_btn_charge.text = "WAIT"
		_btn_charge.tooltip_text = "Animation in progress"
		return
	if _battle_over or _initiative.is_empty() or not _is_player_turn():
		_btn_charge.disabled = true
		_btn_charge.visible = false
		_btn_charge.tooltip_text = ""
		return

	var active := _get_active_unit()
	if active.is_empty() or active.get("skill", "") != "brutal_charge":
		_btn_charge.disabled = true
		_btn_charge.visible = false
		_btn_charge.tooltip_text = ""
		return

	_btn_charge.visible = true
	var can_charge := bool(active.get("has_main_action", true)) and not bool(active.get("has_moved", false))
	var has_target := not _get_charge_target(active).is_empty()
	_btn_charge.disabled = not (can_charge and has_target)
	if not bool(active.get("has_main_action", true)):
		_btn_charge.text = "USED"
		_btn_charge.tooltip_text = "This unit has already used its main action."
	elif bool(active.get("has_moved", false)):
		_btn_charge.text = "MOVED"
		_btn_charge.tooltip_text = "Brutal Charge requires movement to be unused."
	elif not has_target:
		_btn_charge.text = "NO PATH"
		_btn_charge.tooltip_text = "No enemy is reachable in a straight charge lane."
	else:
		_btn_charge.text = "CHARGE"
		_btn_charge.tooltip_text = "Move in a straight line and strike the first enemy reached."



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
	_update_targeting_enabled()
	_update_attack_button_state()
	_update_bonus_button_state()
	_update_charge_button_state()


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
		if _is_blocker(check):
			break
		for u: Dictionary in _units:
			if u["team"] == "enemy" and int(u.get("hp_current", 0)) > 0 and u["grid_pos"] == check:
				return u
	return {}


func _on_charge() -> void:
	if _is_animating or _battle_over or _initiative.is_empty() or not _is_player_turn():
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
		if not _is_in_grid(next) or _is_blocker(next) or _is_tile_occupied(next, unit):
			break
		land = next

	unit["has_moved"] = true
	unit["has_main_action"] = false
	_clear_move_tiles()
	await _move_unit_to(unit, land)
	_update_unit_info(unit)
	_update_charge_button_state()
	_update_attack_button_state()
	_update_bonus_button_state()

	_log("[color=#ffaa00]%s[/color] [color=#00ffcc]CHARGES![/color]" % unit["name"])
	await _apply_attack_direct(unit, target)


func _apply_attack_direct(attacker: Dictionary, target: Dictionary) -> void:
	var killed := await _resolve_attack(attacker, target, "[color=#ffaa00]")
	if killed and _check_battle_end():
		return
	_advance_turn()


func _shove_impact_name(dest: Vector2i, target: Dictionary) -> String:
	if not _is_in_grid(dest):
		return "wall"
	if _is_blocker(dest):
		return "blocker"
	if _is_tile_occupied(dest, target):
		return "unit"
	return "wall"


func _on_shove() -> void:
	if _is_animating or _battle_over or _initiative.is_empty() or not _is_player_turn():
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

	if _is_walkable(dest, target):
		await _move_unit_to(target, dest)
		if _is_hazard(dest):
			_log("[color=#00ffcc]%s[/color] shoved [color=#ff2244]%s[/color] into arena hazard - [color=#ffaa00]%d[/color] dmg!" % [
				unit["name"], target["name"], SHOVE_IMPACT_DAMAGE
			])
			if str(target.get("team", "")) == "enemy":
				_style_score += 1
				_log("[color=#ffaa00]HAZARD POP - STYLE +1[/color]")
				_update_objective_label()
			var hazard_killed := await _apply_damage(target, SHOVE_IMPACT_DAMAGE)
			if hazard_killed and _check_battle_end():
				return
		else:
			_log("[color=#00ffcc]%s[/color] shoved [color=#ff2244]%s[/color] back!" % [unit["name"], target["name"]])
	else:
		var impact_name := _shove_impact_name(dest, target)
		_log("[color=#00ffcc]%s[/color] slammed [color=#ff2244]%s[/color] into %s - [color=#ffaa00]%d[/color] dmg!" % [
			unit["name"], target["name"], impact_name, SHOVE_IMPACT_DAMAGE
		])
		var killed := await _apply_damage(target, SHOVE_IMPACT_DAMAGE)
		if killed and _check_battle_end():
			return

	_update_unit_info(unit)
	_update_targeting_enabled()
	_update_attack_button_state()
	_update_bonus_button_state()
	_update_charge_button_state()


func _on_shield_bash() -> void:
	if _is_animating or _battle_over or _initiative.is_empty() or not _is_player_turn():
		return

	var unit := _get_active_unit()
	if unit.is_empty() or not bool(unit.get("has_bonus_action", true)):
		return

	var target := _get_adjacent_enemy(unit)
	if target.is_empty():
		return

	unit["has_bonus_action"] = false
	var bash_damage := 2
	_log("[color=#00ffcc]%s[/color] shield bashes [color=#ff2244]%s[/color] for [color=#ffaa00]%d[/color] dmg!" % [
		unit["name"], target["name"], bash_damage
	])
	var killed := await _apply_damage(target, bash_damage)
	if killed and _check_battle_end():
		return

	_update_unit_info(unit)
	_update_bonus_button_state()


func _clear_target_selection(update_button := true) -> void:
	_selected_target = null
	_hovered_target = null
	if update_button:
		_update_attack_button_state()
		if not _initiative.is_empty():
			_highlight_active(_initiative[_turn_index])


func _on_unit_gui_input(event: InputEvent, unit: Dictionary) -> void:
	if _is_animating:
		return
	if not _is_targetable(unit):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_selected_target = unit
		_update_attack_button_state()
		_highlight_active(_initiative[_turn_index])
		accept_event()


func _on_unit_mouse_entered(unit: Dictionary) -> void:
	if _is_animating:
		return
	if not _is_targetable(unit):
		return
	_hovered_target = unit
	_highlight_active(_initiative[_turn_index])


func _on_unit_mouse_exited(unit: Dictionary) -> void:
	if _is_animating:
		return
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
			unit["has_moved"] = true
			_log("[color=#ff2244]%s[/color] advanced" % unit["name"])
			await _move_unit_to(unit, destination)

	if _is_in_attack_range(unit, target):
		unit["has_main_action"] = false
		await _apply_attack(unit, target)
	else:
		_advance_turn()


func _on_attack() -> void:
	if _is_animating or _battle_over or _initiative.is_empty():
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
	_update_bonus_button_state()
	_update_charge_button_state()
	_clear_move_tiles()
	_clear_target_selection()
	await _apply_attack(unit, target)


func _on_pass() -> void:
	if _is_animating or _battle_over:
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


func _apply_damage(target: Dictionary, amount: int, show_hit_feedback := true) -> bool:
	var locked_by_damage := false
	target["hp_current"] = maxi(0, int(target["hp_current"]) - amount)
	if target["hp_bar_node"] != null:
		(target["hp_bar_node"] as ProgressBar).value = target["hp_current"]
		_style_hp_row(target, target == _get_active_unit())
	if not _initiative.is_empty() and _units.has(target):
		_update_unit_visual(target, _get_active_unit())
	if show_hit_feedback:
		_set_animating(true)
		locked_by_damage = true
		await _flash_hit(target)
		_show_floating_text("-%d" % amount, _unit_float_position(target), Color(1.0, 0.667, 0.0, 1.0))
	if int(target["hp_current"]) <= 0:
		if str(target["team"]) == "enemy":
			_log("[color=#ff2244]%s[/color] [color=#888888]was eliminated[/color]" % target["name"])
			_kills += 1
			if target.get("is_mark", false):
				_mark_killed = true
			if target == _marked_unit:
				_style_score += 1
				_log("[color=#cc44ff]EXECUTION — STYLE +1[/color]")
				_log("[color=#ffaa00]★ THE CROWD ROARS! ★[/color]")
			_update_objective_label()
		else:
			_log("[color=#00ffcc]%s[/color] [color=#ffaa00]is DOWNED[/color]" % target["name"])
			var ridx: int = int(target.get("roster_index", -1))
			if ridx >= 0 and not _downed_player_indices.has(ridx):
				_downed_player_indices.append(ridx)
		await _play_down_feedback(target)
		if locked_by_damage:
			_set_animating(false)
		_remove_dead(target)
		return true
	if locked_by_damage:
		_set_animating(false)
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
	var attacker_color := "[color=#00ffcc]" if attacker["team"] == "player" else "[color=#ff2244]"
	var killed := await _resolve_attack(attacker, target, attacker_color)
	if killed and _check_battle_end():
		return
	_advance_turn()


func _flash_hit(unit: Dictionary) -> void:
	var visual := unit.get("visual_root", null) as BattleUnitVisual
	if visual != null:
		visual.flash_hit()
	if unit["rect_node"] == null:
		return
	var tex_rect := unit["rect_node"] as TextureRect
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(tex_rect, "modulate", Color(1.7, 0.85, 0.85, 1), 0.06)
	tween.tween_property(tex_rect, "position", tex_rect.position + Vector2(3, 0), 0.04)
	await tween.finished
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(tex_rect, "modulate", Color(1, 1, 1, 1), 0.10)
	if visual == null:
		tween.tween_property(tex_rect, "position", _iso_to_screen(unit["grid_pos"]), 0.08)
	await tween.finished


func _unit_float_position(unit: Dictionary) -> Vector2:
	return _iso_to_screen(unit["grid_pos"]) + Vector2(UNIT_SIZE.x * 0.5, 4)


func _show_floating_text(text: String, world_pos: Vector2, color: Color, crit := false) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_font_size_override("font_size", UITheme.SIZE_XL if crit else UITheme.SIZE_LG)
	lbl.size = Vector2(118 if crit else 96, 30)
	lbl.position = world_pos - Vector2(lbl.size.x * 0.5, 0)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.z_index = 30
	_arena.add_child(lbl)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(lbl, "position", lbl.position + Vector2(0, -28), 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(lbl, "modulate:a", 0.0, 0.55).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.finished.connect(lbl.queue_free)


func _play_attack_feedback(attacker: Dictionary, target: Dictionary, hit: bool, damage: int, crit := false) -> void:
	var attacker_visual := attacker.get("visual_root", null) as BattleUnitVisual
	var target_visual := target.get("visual_root", null) as BattleUnitVisual
	var attacker_node := attacker.get("rect_node", null) as Control
	if attacker_visual != null:
		attacker_node = attacker_visual
	if attacker_node == null or target.get("rect_node", null) == null:
		return

	_set_animating(true)
	var origin := attacker_node.position
	var target_pos := _iso_to_screen(target["grid_pos"])
	var direction := (target_pos - origin).normalized()
	var lunge := origin + direction * 14.0
	if attacker_visual != null:
		attacker_visual.set_facing(target["grid_pos"] - attacker["grid_pos"])

	var is_ranged := int(attacker.get("attack_range", DEFAULT_ATTACK_RANGE)) > 1
	if is_ranged:
		if attacker_visual != null:
			attacker_visual.play("ranged_attack", false)
		BattleCombatEffectScene.play_ranged_streak(_arena, _unit_float_position(attacker), _unit_float_position(target))
		await get_tree().create_timer(ATTACK_LUNGE_DURATION * 2.0).timeout
	else:
		if attacker_visual != null:
			attacker_visual.play("melee_attack", false)
		var tween := create_tween()
		tween.tween_property(attacker_node, "position", lunge, ATTACK_LUNGE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(attacker_node, "position", origin, ATTACK_LUNGE_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished

	if hit:
		if not is_ranged:
			BattleCombatEffectScene.play_melee_hit(_arena, _unit_float_position(attacker), _unit_float_position(target), crit)
		await _flash_hit(target)
		_show_floating_text("CRIT -%d" % damage if crit else "-%d" % damage, _unit_float_position(target), Color(1.0, 0.22, 0.08, 1.0) if crit else Color(1.0, 0.667, 0.0, 1.0), crit)
	else:
		_show_floating_text("MISS", _unit_float_position(target), Color(0.75, 0.75, 0.82, 1.0))
	if attacker_visual != null:
		attacker_visual.play("idle")
	if target_visual != null and int(target.get("hp_current", 1)) > 0:
		target_visual.play("idle")
	_set_animating(false)


func _play_down_feedback(unit: Dictionary) -> void:
	var visual := unit.get("visual_root", null) as BattleUnitVisual
	if visual != null:
		visual.play_down()
	if visual == null and unit.get("rect_node", null) == null:
		await get_tree().create_timer(0.2).timeout
		return
	var rect := unit["rect_node"] as Control
	if visual != null:
		rect = visual
	var ring := unit.get("ring_node", null) as Control
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(rect, "modulate:a", 0.0, 0.25)
	tween.tween_property(rect, "scale", Vector2(0.82, 0.82), 0.25)
	if ring and visual == null:
		tween.tween_property(ring, "modulate:a", 0.0, 0.25)
	await tween.finished


func _remove_dead(unit: Dictionary) -> void:
	if unit.get("visual_root", null) != null:
		(unit["visual_root"] as Control).queue_free()
		unit["visual_root"] = null
		unit["rect_node"] = null
		unit["sprite_node"] = null
		unit["ring_node"] = null
		unit["shadow_node"] = null
		unit["status_node"] = null
	elif unit["rect_node"] != null:
		(unit["rect_node"] as TextureRect).queue_free()
		unit["rect_node"] = null
	if unit.get("ring_node", null) != null:
		(unit["ring_node"] as Control).queue_free()
		unit["ring_node"] = null
	if unit["hp_bar_node"] != null:
		if unit.get("hp_row_node", null) != null:
			(unit["hp_row_node"] as Control).queue_free()
		else:
			(unit["hp_bar_node"] as ProgressBar).get_parent().queue_free()
		unit["hp_bar_node"] = null
		unit["hp_row_node"] = null
		unit["hp_name_node"] = null
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
	_btn_bonus.disabled = true
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
	_resolve_development()
	_resolve_casualties()
	GameState.tick_injuries()
	GameState.save_game()


func _resolve_development() -> void:
	var dev_lines: Array = []
	for unit in _units:
		if unit.get("team", "") != "player":
			continue
		var ridx: int = int(unit.get("roster_index", -1))
		if ridx < 0 or ridx >= GameState.roster.size():
			continue
		var changes: Array = GameState.develop_gladiator(ridx)
		dev_lines.append_array(changes)
	if dev_lines.size() > 0 and _combat_log != null:
		_log("[color=#888888]— DEVELOPMENT —[/color]")
		for line in dev_lines:
			_log(line)


func _resolve_casualties() -> void:
	if _downed_player_indices.is_empty():
		return
	# Process descending so kills don't shift remaining indices.
	var sorted_indices: Array = _downed_player_indices.duplicate()
	sorted_indices.sort()
	sorted_indices.reverse()
	var summary_lines: Array = []
	for idx in sorted_indices:
		if idx < 0 or idx >= GameState.roster.size():
			continue
		var gname: String = str(GameState.roster[idx].get("name", "???"))
		var roll: int = randi_range(1, 10)
		if roll == 1:
			GameState.kill_gladiator(idx)
			summary_lines.append("[color=#ff2244]%s DIED[/color] (roll %d)" % [gname, roll])
		elif roll <= 4:
			var key: String = InjuryData.random_serious()
			GameState.apply_injury(idx, key, 2)
			var display: String = InjuryData.INJURIES[key]["display_name"]
			summary_lines.append("[color=#ffaa00]%s — SERIOUS INJURY: %s[/color] (roll %d)" % [gname, display, roll])
		else:
			var key: String = InjuryData.random_minor()
			GameState.apply_injury(idx, key)
			var display: String = InjuryData.INJURIES[key]["display_name"]
			summary_lines.append("[color=#ffaa00]%s — INJURED: %s[/color] (roll %d)" % [gname, display, roll])
	if summary_lines.size() > 0 and _combat_log != null:
		_log("[color=#888888]— CASUALTY REPORT —[/color]")
		for line in summary_lines:
			_log(line)


func _on_return_to_base() -> void:
	get_tree().change_scene_to_file("res://scenes/Management.tscn")
