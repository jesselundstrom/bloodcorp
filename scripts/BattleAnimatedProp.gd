class_name BattleAnimatedProp
extends TextureRect

# Loops a horizontal sprite sheet (1 row, N frames) for arena hazard props such
# as the electric tesla coil. Mirrors the AtlasTexture frame-cycling idiom used by
# BattleUnitVisual, but trimmed to a single looping animation.

var _sheet: Texture2D
var _frame_count := 1
var _frame_size := Vector2i(64, 64)
var _current_frame := 0
var _elapsed := 0.0
var _frame_duration := 0.1


func setup(sheet: Texture2D, frame_count: int, frame_duration := 0.1) -> void:
	_sheet = sheet
	_frame_count = maxi(1, frame_count)
	_frame_duration = maxf(0.01, frame_duration)
	_frame_size = Vector2i(
		maxi(1, floori(float(_sheet.get_width()) / float(_frame_count))),
		maxi(1, _sheet.get_height())
	)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(_frame_count > 1)
	_apply_frame()


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < _frame_duration:
		return
	_elapsed = 0.0
	_current_frame = (_current_frame + 1) % _frame_count
	_apply_frame()


func _apply_frame() -> void:
	if _sheet == null:
		return
	var atlas := AtlasTexture.new()
	atlas.atlas = _sheet
	atlas.filter_clip = true
	atlas.region = Rect2(_current_frame * _frame_size.x, 0, _frame_size.x, _frame_size.y)
	texture = atlas
