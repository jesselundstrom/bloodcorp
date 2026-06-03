class_name BattleIsoTile
extends Control

const VARIANT_MOVE := "move"
const VARIANT_PATH := "path"
const VARIANT_ATTACK := "attack"
const VARIANT_ATTACK_RANGE := "attack_range"
const VARIANT_VALID_TARGET := "valid_target"
const VARIANT_INVALID_TARGET := "invalid_target"
const VARIANT_BLOCKER := "blocker"
const VARIANT_HAZARD := "hazard"

var fill_color: Color = Color(0, 0, 0, 0)
var border_color: Color = Color(1, 1, 1, 0)
var border_width: float = 2.0
var variant: String = VARIANT_MOVE
var _pulse: float = 0.0


func setup(p_fill: Color, p_border: Color, p_border_width := 2.0, p_variant := VARIANT_MOVE) -> void:
	fill_color = p_fill
	border_color = p_border
	border_width = p_border_width
	variant = p_variant
	set_process(variant == VARIANT_HAZARD)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse = fmod(_pulse + delta, TAU)
	queue_redraw()


func _diamond_points(offset := Vector2.ZERO) -> PackedVector2Array:
	var mid_x := size.x * 0.5
	var mid_y := size.y * 0.5
	return PackedVector2Array([
		Vector2(mid_x, 0) + offset,
		Vector2(size.x, mid_y) + offset,
		Vector2(mid_x, size.y) + offset,
		Vector2(0, mid_y) + offset,
	])


func _draw() -> void:
	match variant:
		VARIANT_BLOCKER:
			_draw_blocker()
		VARIANT_HAZARD:
			_draw_hazard()
		VARIANT_PATH:
			_draw_path()
		VARIANT_ATTACK_RANGE:
			_draw_attack_range()
		VARIANT_VALID_TARGET:
			_draw_target(true)
		VARIANT_INVALID_TARGET:
			_draw_target(false)
		_:
			_draw_basic()


func _draw_basic() -> void:
	var points := _diamond_points()
	draw_polygon(points, PackedColorArray([fill_color]))
	_draw_outline(points, border_color, border_width)


func _draw_path() -> void:
	var points := _diamond_points()
	draw_polygon(points, PackedColorArray([fill_color]))
	var center := size * 0.5
	draw_circle(center, minf(size.x, size.y) * 0.12, Color(1.0, 0.95, 0.55, 0.42))
	_draw_outline(points, border_color, border_width)


func _draw_attack_range() -> void:
	var points := _diamond_points()
	draw_polygon(points, PackedColorArray([fill_color]))
	var center := size * 0.5
	draw_line(Vector2(center.x - size.x * 0.16, center.y), Vector2(center.x + size.x * 0.16, center.y), Color(1.0, 0.22, 0.34, 0.18), 1.0)
	draw_line(Vector2(center.x, center.y - size.y * 0.16), Vector2(center.x, center.y + size.y * 0.16), Color(1.0, 0.22, 0.34, 0.18), 1.0)
	_draw_outline(points, border_color, border_width)


func _draw_target(valid: bool) -> void:
	var points := _diamond_points()
	draw_polygon(points, PackedColorArray([fill_color]))
	var center := size * 0.5
	var color := border_color if valid else Color(0.72, 0.58, 0.62, 0.42)
	var radius := minf(size.x, size.y) * (0.28 if valid else 0.22)
	draw_arc(center, radius, 0, TAU, 28, color, 2.0 if valid else 1.0)
	draw_line(center + Vector2(-radius * 0.7, 0), center + Vector2(radius * 0.7, 0), color, 1.0)
	draw_line(center + Vector2(0, -radius * 0.55), center + Vector2(0, radius * 0.55), color, 1.0)
	_draw_outline(points, border_color, border_width)


func _draw_blocker() -> void:
	var shadow := _diamond_points(Vector2(0, 4))
	draw_polygon(shadow, PackedColorArray([Color(0, 0, 0, 0.36)]))

	var points := _diamond_points()
	draw_polygon(points, PackedColorArray([fill_color]))
	var inner := PackedVector2Array([
		Vector2(size.x * 0.5, size.y * 0.15),
		Vector2(size.x * 0.84, size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.84),
		Vector2(size.x * 0.16, size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.15),
	])
	draw_polyline(inner, Color(0.95, 0.62, 0.12, 0.30), 1.0, true)
	draw_line(Vector2(size.x * 0.26, size.y * 0.5), Vector2(size.x * 0.74, size.y * 0.5), Color(0, 0, 0, 0.26), 1.0)
	_draw_outline(points, border_color, border_width)


func _draw_hazard() -> void:
	var pulse_alpha := 0.10 + 0.08 * (sin(_pulse * 3.0) * 0.5 + 0.5)
	var glow := _diamond_points(Vector2(0, 1))
	draw_polygon(glow, PackedColorArray([Color(1.0, 0.24, 0.04, pulse_alpha)]))

	var points := _diamond_points()
	draw_polygon(points, PackedColorArray([fill_color]))
	for i in range(3):
		var y := size.y * (0.33 + float(i) * 0.16)
		draw_line(Vector2(size.x * 0.28, y), Vector2(size.x * 0.72, y), Color(1.0, 0.68, 0.0, 0.26), 1.0)
	_draw_outline(points, border_color.lightened(0.18), border_width)
	_draw_outline(_diamond_points(Vector2(0, -1)), Color(1.0, 0.12, 0.08, 0.26), 1.0)


func _draw_outline(points: PackedVector2Array, color: Color, width: float) -> void:
	if color.a <= 0.0 or width <= 0.0:
		return
	var outline := PackedVector2Array(points)
	outline.append(points[0])
	draw_polyline(outline, color, width, true)
