class_name BattleUnitVisual
extends Control

class ShadowNode:
	extends Control

	func _draw() -> void:
		var points := PackedVector2Array([
			Vector2(size.x * 0.5, size.y * 0.12),
			Vector2(size.x * 0.95, size.y * 0.5),
			Vector2(size.x * 0.5, size.y * 0.88),
			Vector2(size.x * 0.05, size.y * 0.5),
		])
		draw_polygon(points, PackedColorArray([Color(0, 0, 0, 0.34)]))


class RingNode:
	extends Control

	var ring_color: Color = Color(0, 0, 0, 0)
	var ring_width: float = 2.0

	func setup(p_color: Color, p_width := 2.0) -> void:
		ring_color = p_color
		ring_width = p_width
		queue_redraw()

	func _draw() -> void:
		if ring_color.a <= 0.0 or ring_width <= 0.0:
			return
		var points := PackedVector2Array([
			Vector2(size.x * 0.5, 0),
			Vector2(size.x, size.y * 0.5),
			Vector2(size.x * 0.5, size.y),
			Vector2(0, size.y * 0.5),
			Vector2(size.x * 0.5, 0),
		])
		draw_polyline(points, ring_color, ring_width, true)


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

var shadow_node: ShadowNode
var ring_node: RingNode
var sprite_node: TextureRect
var status_node: StatusNode

var _sheet_texture: Texture2D
var _fallback_texture: Texture2D
var _frame_size := Vector2i(128, 128)
var _frame_columns := 6
var _animated := false
var _current_anim := "idle"
var _current_frame := 0
var _anim_elapsed := 0.0
var _frame_duration := 0.15
var _loop_anim := true
var _facing_left := false
var _active_idle := false
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

	ring_node = RingNode.new()
	ring_node.size = ring_size
	ring_node.position = shadow_node.position
	ring_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ring_node.z_index = 1
	add_child(ring_node)

	sprite_node = TextureRect.new()
	sprite_node.size = Vector2(72, 72)
	sprite_node.custom_minimum_size = sprite_node.size
	sprite_node.pivot_offset = sprite_node.size * 0.5
	_sprite_base_pos = Vector2((unit_size.x - sprite_node.size.x) * 0.5, -18)
	sprite_node.position = _sprite_base_pos
	sprite_node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite_node.z_index = 2
	add_child(sprite_node)

	status_node = StatusNode.new()
	status_node.size = Vector2(24, 18)
	status_node.position = Vector2(unit_size.x - 18, -4)
	status_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	status_node.z_index = 3
	add_child(status_node)


func set_texture_source(sheet_texture: Texture2D, fallback_texture: Texture2D) -> void:
	_sheet_texture = sheet_texture
	_fallback_texture = fallback_texture
	_animated = _sheet_texture != null and _sheet_texture.get_width() >= 6 and _sheet_texture.get_height() >= 6
	if _animated:
		_frame_size = Vector2i(maxi(1, floori(float(_sheet_texture.get_width()) / 6.0)), maxi(1, floori(float(_sheet_texture.get_height()) / 6.0)))
		_frame_columns = 6
		play("idle")
	else:
		sprite_node.texture = _fallback_texture


func play(anim_name: String, loop := true) -> void:
	if not _animated:
		return
	if not ANIM_ROWS.has(anim_name):
		anim_name = "idle"
	_current_anim = anim_name
	_current_frame = 0
	_anim_elapsed = 0.0
	_loop_anim = loop
	_apply_frame()


func set_facing(direction: Vector2i) -> void:
	if direction == Vector2i.ZERO:
		return
	_facing_left = (direction.x - direction.y) < 0
	sprite_node.scale.x = -1.0 if _facing_left else 1.0


func set_state(state: Dictionary) -> void:
	var hovered := bool(state.get("hovered", false))
	var targetable := bool(state.get("targetable", false))
	sprite_node.modulate = Color(1.28, 1.28, 1.28, 1.0) if hovered and targetable else Color(1, 1, 1, 1)

	if bool(state.get("selected", false)):
		ring_node.setup(Color(1, 1, 1, 1), 3.0)
	elif hovered and targetable:
		ring_node.setup(Color(1, 1, 1, 0.45), 2.0)
	elif bool(state.get("active", false)):
		ring_node.setup(Color(0.0, 1.0, 0.8, 0.85), 2.0)
	elif bool(state.get("sponsor_mark", false)):
		ring_node.setup(Color(1.0, 0.667, 0.0, 0.9), 2.0)
	elif bool(state.get("execution_mark", false)):
		ring_node.setup(Color(0.8, 0.0, 1.0, 1.0), 2.0)
	else:
		ring_node.setup(Color(0, 0, 0, 0), 0.0)

	var mark_color := Color(0, 0, 0, 0)
	if bool(state.get("execution_mark", false)):
		mark_color = Color(0.8, 0.0, 1.0, 1.0)
	elif bool(state.get("sponsor_mark", false)):
		mark_color = Color(1.0, 0.667, 0.0, 1.0)
	status_node.setup(mark_color, bool(state.get("low_hp", false)))
	set_active_idle(bool(state.get("active", false)))


func set_active_idle(enabled: bool) -> void:
	_active_idle = enabled


func flash_hit() -> void:
	play("hit", false)


func play_down() -> void:
	play("downed", false)


func _process(delta: float) -> void:
	_idle_time += delta
	var bob_amp := 1.8 if _active_idle else 0.55
	var bob := sin(_idle_time * (3.8 if _active_idle else 2.4)) * bob_amp
	sprite_node.position = _sprite_base_pos + Vector2(0, bob)

	if not _animated:
		return
	_anim_elapsed += delta
	if _anim_elapsed < _frame_duration:
		return
	_anim_elapsed = 0.0
	var frame_count: int = int(ANIM_FRAMES.get(_current_anim, 1))
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
	atlas.region = Rect2(
		_current_frame * _frame_size.x,
		int(ANIM_ROWS.get(_current_anim, 0)) * _frame_size.y,
		_frame_size.x,
		_frame_size.y
	)
	sprite_node.texture = atlas
