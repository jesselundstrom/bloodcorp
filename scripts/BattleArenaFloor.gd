class_name BattleArenaFloor
extends Control

var grid_cols := 9
var grid_rows := 6
var tile_size := Vector2(42, 28)
var unit_size := Vector2(56, 56)
var board_center_ratio := Vector2(0.50, 0.56)
var board_size_ratio := Vector2(0.52, 0.42)
var accent_color := Color(0.0, 1.0, 0.8, 1.0)
var enemy_color := Color(1.0, 0.133, 0.267, 1.0)
var warning_color := Color(1.0, 0.667, 0.0, 1.0)
var valid_tiles: Array = []
var show_lattice := false


func setup(cols: int, rows: int, p_tile_size: Vector2, p_unit_size: Vector2, p_board_center_ratio: Vector2, p_board_size_ratio: Vector2, p_valid_tiles: Array = []) -> void:
	grid_cols = cols
	grid_rows = rows
	tile_size = p_tile_size
	unit_size = p_unit_size
	board_center_ratio = p_board_center_ratio
	board_size_ratio = p_board_size_ratio
	valid_tiles = p_valid_tiles.duplicate()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	if show_lattice:
		_draw_grid_lattice()
	_draw_broadcast_marks()


func _draw_grid_lattice() -> void:
	var tiles := valid_tiles
	if tiles.is_empty():
		for y in range(grid_rows):
			for x in range(grid_cols):
				tiles.append(Vector2i(x, y))
	for pos: Vector2i in tiles:
		var center := _grid_center(pos)
		var points := _diamond(center, tile_size * 0.94)
		draw_polyline(_closed(points), Color(0.0, 1.0, 0.8, 0.075), 1.0, true)


func _draw_broadcast_marks() -> void:
	var center := Vector2(size.x * 0.5, size.y * 0.48)
	var left := center + Vector2(-size.x * 0.29, -size.y * 0.05)
	var right := center + Vector2(size.x * 0.29, size.y * 0.08)
	_draw_corp_chevrons(left, accent_color, -1.0)
	_draw_corp_chevrons(right, enemy_color, 1.0)

	var marker_y := size.y * 0.2
	for i in range(6):
		var x := size.x * 0.38 + i * 18.0
		var h := 10.0 + float((i * 7) % 19)
		draw_rect(Rect2(Vector2(x, marker_y), Vector2(7, h)), Color(warning_color.r, warning_color.g, warning_color.b, 0.045))


func _draw_corp_chevrons(origin: Vector2, color: Color, dir: float) -> void:
	for i in range(3):
		var offset := Vector2(float(i) * 15.0 * dir, float(i) * 6.0)
		var points := PackedVector2Array([
			origin + offset + Vector2(-10.0 * dir, -5.0),
			origin + offset + Vector2(0.0, 0.0),
			origin + offset + Vector2(-10.0 * dir, 5.0),
		])
		draw_polyline(points, Color(color.r, color.g, color.b, 0.075), 2.0, true)


func _grid_center(grid_pos: Vector2i) -> Vector2:
	var board_center := size * board_center_ratio
	var board_size := size * board_size_ratio
	var diff_min := -float(grid_rows - 1)
	var diff_max := float(grid_cols - 1)
	var sum_min := 0.0
	var sum_max := float(grid_cols + grid_rows - 2)
	var diff := float(grid_pos.x - grid_pos.y)
	var sum := float(grid_pos.x + grid_pos.y)
	var nx := inverse_lerp(diff_min, diff_max, diff) - 0.5
	var ny := inverse_lerp(sum_min, sum_max, sum) - 0.5
	return board_center + Vector2(nx * board_size.x, ny * board_size.y)


func _diamond(center: Vector2, dimensions: Vector2) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0, -dimensions.y * 0.5),
		center + Vector2(dimensions.x * 0.5, 0),
		center + Vector2(0, dimensions.y * 0.5),
		center + Vector2(-dimensions.x * 0.5, 0),
	])


func _ellipse_points(center: Vector2, radius: Vector2, steps: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(steps):
		var t := TAU * float(i) / float(steps)
		points.append(center + Vector2(cos(t) * radius.x, sin(t) * radius.y))
	return points


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array(points)
	if points.size() > 0:
		out.append(points[0])
	return out
