class_name BattleUnitVisual
extends Control

class ShadowNode:
	extends Control

	func _draw() -> void:
		var center := size * 0.5
		var radius := Vector2(size.x * 0.50, size.y * 0.31)
		_draw_ellipse_fill(center + Vector2(0, 1), radius, Color(0, 0, 0, 0.30))
		_draw_ellipse_fill(center, radius * 0.58, Color(0, 0, 0, 0.18))

	func _draw_ellipse_fill(center: Vector2, radius: Vector2, color: Color) -> void:
		var points := PackedVector2Array()
		for i in range(40):
			var t := TAU * float(i) / 40.0
			points.append(center + Vector2(cos(t) * radius.x, sin(t) * radius.y))
		draw_polygon(points, PackedColorArray([color]))


class RingNode:
	extends Control

	var ring_color: Color = Color(0, 0, 0, 0)
	var ring_width: float = 2.0
	var pulse_enabled := false
	var _pulse := 0.0

	func setup(p_color: Color, p_width := 2.0, p_pulse := false) -> void:
		ring_color = p_color
		ring_width = p_width
		pulse_enabled = p_pulse
		set_process(pulse_enabled)
		queue_redraw()

	func _process(delta: float) -> void:
		_pulse = fmod(_pulse + delta * 4.2, TAU)
		queue_redraw()

	func _draw() -> void:
		if ring_color.a <= 0.0 or ring_width <= 0.0:
			return
		var center := size * 0.5
		var radius := Vector2(size.x * 0.42, size.y * 0.27)
		if pulse_enabled:
			var pulse_alpha := 0.14 + 0.16 * (sin(_pulse) * 0.5 + 0.5)
			var pulse_color := Color(ring_color.r, ring_color.g, ring_color.b, pulse_alpha)
			_draw_ellipse_outline(center, radius * 1.16, pulse_color, ring_width + 4.0)
			_draw_ellipse_outline(center, radius * 0.76, Color(pulse_color.r, pulse_color.g, pulse_color.b, pulse_color.a * 0.45), ring_width + 2.0)
		_draw_ellipse_outline(center, radius, ring_color, ring_width)

	func _draw_ellipse_outline(center: Vector2, radius: Vector2, color: Color, width: float) -> void:
		var points := PackedVector2Array()
		for i in range(41):
			var t := TAU * float(i) / 40.0
			points.append(center + Vector2(cos(t) * radius.x, sin(t) * radius.y))
		draw_polyline(points, color, width, true)


class StatusNode:
	extends Control

	var mark_color: Color = Color(0, 0, 0, 0)
	var low_hp: bool = false

	func setup(p_mark_color: Color, p_low_hp: bool) -> void:
		mark_color = p_mark_color
		low_hp = p_low_hp
		queue_redraw()

	func _draw() -> void:
		if mark_color.a > 0.0:
			draw_circle(Vector2(size.x - 8, 8), 4.0, mark_color)
			draw_circle(Vector2(size.x - 8, 8), 2.0, Color(1, 1, 1, 0.65))
		if low_hp:
			var tri := PackedVector2Array([
				Vector2(5, 2),
				Vector2(11, 13),
				Vector2(0, 13),
			])
			draw_polygon(tri, PackedColorArray([Color(1.0, 0.18, 0.08, 0.95)]))


class HpBarNode:
	extends Control

	var hp_current := 1
	var hp_max := 1
	var team_color := Color(0.0, 1.0, 0.8, 1.0)
	var active := false

	func setup(p_current: int, p_max: int, p_team_color: Color, p_active: bool) -> void:
		hp_current = maxi(0, p_current)
		hp_max = maxi(1, p_max)
		team_color = p_team_color
		active = p_active
		visible = hp_current > 0
		queue_redraw()

	func _draw() -> void:
		if hp_current <= 0:
			return
		var pct := clampf(float(hp_current) / float(hp_max), 0.0, 1.0)
		var outline_color := Color(1, 1, 1, 0.75) if active else Color(0, 0, 0, 0.86)
		var fill_color := team_color
		if pct <= 0.33:
			fill_color = Color(1.0, 0.18, 0.08, 1.0)
		elif pct <= 0.66:
			fill_color = Color(1.0, 0.667, 0.0, 1.0)

		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.74))
		draw_rect(Rect2(Vector2(1, 1), Vector2(maxf(1.0, (size.x - 2.0) * pct), size.y - 2.0)), fill_color)
		draw_rect(Rect2(Vector2.ZERO, size), outline_color, false, 1.0)


const ANIM_ROWS := {
	"idle": 0,
	"walk": 1,
	"melee_attack": 2,
	"ranged_attack": 3,
	"hit": 4,
	"downed": 5,
}
const ANIM_FRAMES := {
	"idle": 4,
	"walk": 6,
	"melee_attack": 4,
	"ranged_attack": 4,
	"hit": 2,
	"downed": 4,
}
const ANIM_FRAME_DURATIONS := {
	"walk": 0.08,
	"melee_attack": 0.045,
	"ranged_attack": 0.055,
	"hit": 0.04,
	"downed": 0.055,
}

var shadow_node: ShadowNode
var base_ring_node: RingNode
var ring_node: RingNode
var sprite_node: TextureRect
var status_node: StatusNode
var hp_bar_node: HpBarNode
var nameplate_node: PanelContainer
var nameplate_accent: ColorRect
var nameplate_name: Label
var nameplate_hp: Label

var _sheet_texture: Texture2D
var _fallback_texture: Texture2D
var _frame_size := Vector2i(128, 128)
var _frame_columns := 6
var _animated := false
var _detected_frames := {}  # anim_name -> actual frame count detected from sheet
var _current_anim := "idle"
var _current_frame := 0
var _anim_elapsed := 0.0
var _frame_duration := 0.12
var _loop_anim := true
var _advance_frames := true
var _facing_left := false
var _active_idle := false
var _is_walking := false
var _idle_time := 0.0
var _unit_size := Vector2(56, 56)
var _sprite_base_pos := Vector2.ZERO


func setup(unit_size: Vector2, ring_size: Vector2) -> void:
	_unit_size = unit_size
	size = unit_size
	custom_minimum_size = unit_size
	pivot_offset = unit_size * 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP

	shadow_node = ShadowNode.new()
	shadow_node.size = ring_size
	shadow_node.position = Vector2((unit_size.x - ring_size.x) * 0.5, unit_size.y - ring_size.y * 0.70)
	shadow_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shadow_node.z_index = 0
	add_child(shadow_node)

	base_ring_node = RingNode.new()
	base_ring_node.size = ring_size
	base_ring_node.position = shadow_node.position
	base_ring_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	base_ring_node.z_index = 1
	add_child(base_ring_node)

	ring_node = RingNode.new()
	ring_node.size = ring_size
	ring_node.position = shadow_node.position
	ring_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring_node.z_index = 2
	add_child(ring_node)

	sprite_node = TextureRect.new()
	sprite_node.size = Vector2(96, 96) * (unit_size.x / 56.0)
	sprite_node.custom_minimum_size = sprite_node.size
	sprite_node.pivot_offset = sprite_node.size * 0.5
	_sprite_base_pos = Vector2((unit_size.x - sprite_node.size.x) * 0.5, -28 * (unit_size.x / 56.0))
	sprite_node.position = _sprite_base_pos
	sprite_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite_node.z_index = 3
	add_child(sprite_node)

	status_node = StatusNode.new()
	status_node.size = Vector2(24, 18)
	status_node.position = Vector2(unit_size.x - 18, -4)
	status_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_node.z_index = 4
	add_child(status_node)

	hp_bar_node = HpBarNode.new()
	hp_bar_node.size = Vector2(42, 5) * (unit_size.x / 56.0)
	hp_bar_node.position = Vector2((unit_size.x - hp_bar_node.size.x) * 0.5, -27)
	hp_bar_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hp_bar_node.z_index = 5
	add_child(hp_bar_node)

	_build_nameplate(unit_size)


func _build_nameplate(unit_size: Vector2) -> void:
	nameplate_node = PanelContainer.new()
	nameplate_node.visible = false
	nameplate_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	nameplate_node.custom_minimum_size = Vector2(104, 30)
	nameplate_node.position = Vector2((unit_size.x - nameplate_node.custom_minimum_size.x) * 0.5, -58 * (unit_size.x / 56.0))
	nameplate_node.z_index = 6
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.0, 0.0, 0.0, 0.72)
	panel_style.border_color = Color(1, 1, 1, 0.22)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(3)
	panel_style.content_margin_left = 5
	panel_style.content_margin_right = 5
	panel_style.content_margin_top = 3
	panel_style.content_margin_bottom = 3
	nameplate_node.add_theme_stylebox_override("panel", panel_style)
	add_child(nameplate_node)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	nameplate_node.add_child(row)

	nameplate_accent = ColorRect.new()
	nameplate_accent.custom_minimum_size = Vector2(4, 22)
	nameplate_accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(nameplate_accent)

	var labels := VBoxContainer.new()
	labels.add_theme_constant_override("separation", 0)
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(labels)

	nameplate_name = Label.new()
	nameplate_name.clip_text = true
	nameplate_name.add_theme_font_size_override("font_size", 14)
	nameplate_name.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	labels.add_child(nameplate_name)

	nameplate_hp = Label.new()
	nameplate_hp.clip_text = true
	nameplate_hp.add_theme_font_size_override("font_size", 12)
	nameplate_hp.add_theme_color_override("font_color", Color(0.78, 0.82, 0.90, 1))
	labels.add_child(nameplate_hp)


func set_texture_source(sheet_texture: Texture2D, fallback_texture: Texture2D, frame_overrides: Dictionary = {}) -> void:
	_sheet_texture = sheet_texture
	_fallback_texture = fallback_texture
	_animated = _sheet_texture != null and _sheet_texture.get_width() >= 6 and _sheet_texture.get_height() >= 6
	if _animated:
		_detected_frames = frame_overrides.duplicate()
		var max_frames := 1
		for v in _detected_frames.values():
			max_frames = maxi(max_frames, int(v))
		_frame_columns = max_frames if max_frames > 1 else 6
		_frame_size = Vector2i(maxi(1, floori(float(_sheet_texture.get_width()) / float(_frame_columns))), maxi(1, floori(float(_sheet_texture.get_height()) / 6.0)))
		play("idle")
	else:
		sprite_node.texture = _fallback_texture


func play(anim_name: String, loop := true) -> void:
	if not ANIM_ROWS.has(anim_name):
		anim_name = "idle"
	_is_walking = anim_name == "walk"
	if not _animated:
		return
	_current_anim = anim_name
	_current_frame = 0
	_anim_elapsed = 0.0
	_frame_duration = float(ANIM_FRAME_DURATIONS.get(anim_name, 0.12))
	_loop_anim = loop
	_advance_frames = anim_name != "idle"
	_apply_frame()


func set_facing(direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		return
	_facing_left = (direction.x - direction.y) < 0


func set_state(state: Dictionary) -> void:
	var hovered := bool(state.get("hovered", false))
	var targetable := bool(state.get("targetable", false))
	var active := bool(state.get("active", false))
	var selected := bool(state.get("selected", false))
	var team_color: Color = state.get("team_color", Color(0.0, 1.0, 0.8, 1.0))
	sprite_node.modulate = Color(1.28, 1.28, 1.28, 1.0) if hovered and targetable else Color(1, 1, 1, 1)

	if targetable:
		base_ring_node.setup(Color(1.0, 0.133, 0.267, 0.22), 1.0)
	else:
		base_ring_node.setup(Color(team_color.r, team_color.g, team_color.b, 0.13), 1.0)
	if selected:
		ring_node.setup(Color(1, 1, 1, 0.92), 3.0, true)
	elif targetable:
		ring_node.setup(Color(1.0, 0.133, 0.267, 0.88), 2.5, true)
	elif active:
		ring_node.setup(Color(team_color.r, team_color.g, team_color.b, 0.82), 3.0, true)
	elif bool(state.get("sponsor_mark", false)):
		ring_node.setup(Color(1.0, 0.667, 0.0, 0.76), 2.0)
	elif bool(state.get("execution_mark", false)):
		ring_node.setup(Color(0.8, 0.0, 1.0, 0.82), 2.0)
	else:
		ring_node.setup(Color(0, 0, 0, 0), 0.0)

	var mark_color := Color(0, 0, 0, 0)
	if bool(state.get("execution_mark", false)):
		mark_color = Color(0.8, 0.0, 1.0, 1.0)
	elif bool(state.get("sponsor_mark", false)):
		mark_color = Color(1.0, 0.667, 0.0, 1.0)
	status_node.setup(mark_color, bool(state.get("low_hp", false)))
	hp_bar_node.active = active
	hp_bar_node.queue_redraw()
	set_active_idle(active)
	_update_nameplate(state, team_color, active, hovered, selected)


func _update_nameplate(state: Dictionary, team_color: Color, active: bool, hovered: bool, selected: bool) -> void:
	if nameplate_node == null:
		return
	nameplate_node.visible = active or hovered or selected
	if not nameplate_node.visible:
		return
	nameplate_accent.color = team_color
	nameplate_name.text = str(state.get("unit_name", "UNIT")).to_upper()
	nameplate_hp.text = "HP %d/%d" % [int(state.get("hp_current", 0)), int(state.get("hp_max", 1))]


func set_hp(current: int, maximum: int, team_color: Color, active := false) -> void:
	if hp_bar_node == null:
		return
	hp_bar_node.setup(current, maximum, team_color, active)


func set_active_idle(enabled: bool) -> void:
	_active_idle = enabled


func flash_hit() -> void:
	play("hit", false)


func play_down() -> void:
	play("downed", false)


func _process(delta: float) -> void:
	_idle_time += delta

	var facing_sign := -1.0 if _facing_left else 1.0
	sprite_node.scale = Vector2(facing_sign, 1.0)
	if _is_walking:
		sprite_node.position = _sprite_base_pos
	else:
		var bob_amp := 1.35 if _active_idle else 0.28
		var bob := sin(_idle_time * 3.0) * bob_amp
		sprite_node.position = _sprite_base_pos + Vector2(0, bob)

	if not _animated or not _advance_frames:
		return
	_anim_elapsed += delta
	if _anim_elapsed < _frame_duration:
		return
	_anim_elapsed = 0.0
	var frame_count: int = int(_detected_frames.get(_current_anim, ANIM_FRAMES.get(_current_anim, 1)))
	_current_frame += 1
	if _current_frame >= frame_count:
		if _loop_anim:
			_current_frame = 0
		else:
			_current_frame = frame_count - 1
	_apply_frame()


func _apply_frame() -> void:
	if _sheet_texture == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = _sheet_texture
	atlas.filter_clip = true
	atlas.region = Rect2(
		_current_frame * _frame_size.x,
		int(ANIM_ROWS.get(_current_anim, 0)) * _frame_size.y,
		_frame_size.x,
		_frame_size.y
	)
	sprite_node.texture = atlas
