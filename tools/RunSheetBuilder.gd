extends Node

const FRAME_PX := 248
const MAX_COLS := 9
const TARGET_BODY_SIZE := Vector2i(140, 160)
const FOOTLINE_Y := 186
const DOWNED_ROW := 5
const OUTPUT_PATH := "res://assets/sprites/gladiators/enemy_bruiser.png"

# Row order matches ANIM_ROWS in BattleUnitVisual.gd:
#   0=idle  1=walk  2=melee_attack  3=ranged_attack  4=hit  5=downed
# ranged_attack reuses melee_attack frames (bruiser has no ranged weapon).
const ANIM_CONFIG: Array = [
	["idle", 9, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/60500b4a-9a48-4954-b29e-72e3f5cd64d4/south-east/8.png",
	]],
	["walk", 9, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/b9ce4817-f344-48fe-a433-acb4ba081b0c/south-east/8.png",
	]],
	["melee_attack", 9, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/8.png",
	]],
	["ranged_attack", 9, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/1cc2bd3f-64d1-48ab-acd5-2df1281cf434/south-east/8.png",
	]],
	["hit", 9, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/8c0c4188-cd41-4308-b4fc-8e3a3e6c0957/south-east/8.png",
	]],
	["downed", 9, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/8d6ac6b0-909e-406f-9eb5-9003a58f3bd2/animations/c238dafc-6924-4919-91a2-ddf0d0bf9ead/south-east/8.png",
	]],
]

var _pending: Array = []
var _images: Dictionary = {}
var _total := 0
var _done := 0
var _http: HTTPRequest


func _ready() -> void:
	print("SheetBuilder: starting download of enemy_bruiser frames (south-east, 248px)...")
	for row in range(ANIM_CONFIG.size()):
		var frame_count: int = int(ANIM_CONFIG[row][1])
		var urls: Array = ANIM_CONFIG[row][2]
		for col in range(mini(frame_count, urls.size())):
			_pending.append({"row": row, "col": col, "url": urls[col]})
	_total = _pending.size()
	_next()


func _next() -> void:
	if _pending.is_empty():
		_assemble()
		return
	var job: Dictionary = _pending.pop_front()
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_done.bind(job))
	_http.request(job["url"])


func _on_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray, job: Dictionary) -> void:
	_http.queue_free()
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		var img := Image.new()
		if img.load_png_from_buffer(body) == OK:
			_images["%d_%d" % [job["row"], job["col"]]] = _normalize_frame(img, int(job["row"]))
			_done += 1
			print("  [%d/%d] row=%d col=%d OK" % [_done, _total, job["row"], job["col"]])
		else:
			print("  ERROR: bad PNG row=%d col=%d" % [job["row"], job["col"]])
	else:
		print("  ERROR: HTTP %d result=%d row=%d col=%d" % [code, result, job["row"], job["col"]])
	_next()


func _assemble() -> void:
	var rows := ANIM_CONFIG.size()
	var sheet := Image.create(MAX_COLS * FRAME_PX, rows * FRAME_PX, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	for row in range(rows):
		for col in range(MAX_COLS):
			var key := "%d_%d" % [row, col]
			if _images.has(key):
				sheet.blit_rect(_images[key], Rect2i(0, 0, FRAME_PX, FRAME_PX), Vector2i(col * FRAME_PX, row * FRAME_PX))
	var out := ProjectSettings.globalize_path(OUTPUT_PATH)
	if sheet.save_png(out) == OK:
		print("SheetBuilder: DONE -> %s (%dx%d)" % [out, sheet.get_width(), sheet.get_height()])
		print('"enemy_bruiser": {"idle":9,"walk":9,"melee_attack":9,"ranged_attack":9,"hit":9,"downed":9}')
	else:
		print("SheetBuilder: ERROR saving to %s" % out)
	get_tree().quit()


func _normalize_frame(src: Image, row: int) -> Image:
	var bounds := _alpha_bounds(src)
	var frame := Image.create(FRAME_PX, FRAME_PX, false, Image.FORMAT_RGBA8)
	frame.fill(Color(0, 0, 0, 0))
	if bounds.size.x <= 0 or bounds.size.y <= 0:
		return frame

	var cropped := Image.create(bounds.size.x, bounds.size.y, false, Image.FORMAT_RGBA8)
	cropped.fill(Color(0, 0, 0, 0))
	cropped.blit_rect(src, bounds, Vector2i.ZERO)
	var target_size := TARGET_BODY_SIZE
	if row == DOWNED_ROW and bounds.size.x > bounds.size.y * 1.35:
		var scale := minf(170.0 / float(bounds.size.x), 88.0 / float(bounds.size.y))
		target_size = Vector2i(maxi(1, roundi(bounds.size.x * scale)), maxi(1, roundi(bounds.size.y * scale)))
	cropped.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)

	var paste_x := floori((FRAME_PX - target_size.x) * 0.5)
	var paste_y := (178 if row == DOWNED_ROW and target_size.y < TARGET_BODY_SIZE.y else FOOTLINE_Y) - target_size.y
	frame.blit_rect(cropped, Rect2i(0, 0, target_size.x, target_size.y), Vector2i(paste_x, paste_y))
	return frame


func _alpha_bounds(img: Image) -> Rect2i:
	var min_x := img.get_width()
	var min_y := img.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			if img.get_pixel(x, y).a > 0.03:
				min_x = mini(min_x, x)
				min_y = mini(min_y, y)
				max_x = maxi(max_x, x)
				max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i(0, 0, 0, 0)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)
