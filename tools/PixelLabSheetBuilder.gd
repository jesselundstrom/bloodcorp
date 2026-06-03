@tool
extends EditorScript

# PixelLabSheetBuilder - assembles PixelLab animation frame URLs into a sprite sheet.
#
# USAGE: Open this script in the Godot Script editor, then File > Run (Ctrl+Shift+X).
# Downloads each frame from PixelLab and stitches them into OUTPUT_PATH.
#
# Sheet layout: 6 rows (one per animation state), MAX_COLS columns.
# PixelLab source frames are normalized into 209x209 cells so enemies match
# the player gladiator sheets at battle scale.

const FRAME_PX := 209
const MAX_COLS := 6
const TARGET_BODY_SIZE := Vector2i(140, 160)
const FOOTLINE_Y := 186
const DOWNED_ROW := 5

const OUTPUT_PATH := "res://assets/sprites/gladiators/enemy_bruiser.png"

# Row order must match ANIM_ROWS in BattleUnitVisual.gd:
#   idle=0, walk=1, melee_attack=2, ranged_attack=3, hit=4, downed=5
const ANIM_CONFIG: Array = [
	# [row_name, frame_count, [url0..url8]]
	["idle", 6, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/70330128-8ec6-48bd-a118-38c49f199f76/south/8.png",
	]],
	["walk", 6, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/db70fcfa-6238-46ad-b7ff-35e0f8e10c35/south/8.png",
	]],
	["melee_attack", 5, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/0a19934a-01f5-44b9-ac95-3aab37871a95/south/8.png",
	]],
	["ranged_attack", 4, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/398e0131-ce28-4a27-b390-b4bea1aa26cf/south/8.png",
	]],
	["hit", 3, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/622369c0-2c4d-4e15-8002-082da38650d6/south/8.png",
	]],
	["downed", 6, [
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/0.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/1.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/2.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/3.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/4.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/5.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/6.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/7.png",
		"https://backblaze.pixellab.ai/file/pixellab-characters/7e48fd7f-9472-4c22-9d8a-22ae0f2eaab5/33852c88-db36-4ccb-bc98-26f77cd64252/animations/7f9235af-b123-4d5b-8dd1-c91d2416e123/south/8.png",
	]],
]

# ---------------------------------------------------------------------------

var _http: HTTPRequest
var _pending_downloads: Array = []
var _frame_images: Dictionary = {}  # "row_col" -> Image
var _total := 0
var _done := 0


func _run() -> void:
	_enqueue_all_downloads()
	_total = _pending_downloads.size()
	_done = 0
	print("PixelLabSheetBuilder: downloading %d frames for enemy_bruiser..." % _total)
	_download_next()


func _enqueue_all_downloads() -> void:
	var row := 0
	for entry in ANIM_CONFIG:
		var frame_count: int = int(entry[1])
		var urls: Array = entry[2]
		for col in range(mini(frame_count, urls.size())):
			_pending_downloads.append({"row": row, "col": col, "url": urls[col]})
		row += 1


func _download_next() -> void:
	if _pending_downloads.is_empty():
		_assemble_sheet()
		return
	var job: Dictionary = _pending_downloads.pop_front()
	_http = HTTPRequest.new()
	EditorInterface.get_base_control().add_child(_http)
	_http.request_completed.connect(_on_download_complete.bind(job))
	var err := _http.request(job["url"])
	if err != OK:
		push_error("PixelLabSheetBuilder: HTTP request failed for row=%d col=%d" % [job["row"], job["col"]])
		_http.queue_free()
		_download_next()


func _on_download_complete(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, job: Dictionary) -> void:
	_http.queue_free()
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		push_error("PixelLabSheetBuilder: download failed (result=%d code=%d) for row=%d col=%d" % [result, response_code, job["row"], job["col"]])
	else:
		var img := Image.new()
		var load_err := img.load_png_from_buffer(body)
		if load_err != OK:
			push_error("PixelLabSheetBuilder: could not parse PNG for row=%d col=%d" % [job["row"], job["col"]])
		else:
			_frame_images["%d_%d" % [job["row"], job["col"]]] = _normalize_frame(img, int(job["row"]))
	_done += 1
	print("  [%d/%d] row=%d col=%d" % [_done, _total, job["row"], job["col"]])
	_download_next()


func _assemble_sheet() -> void:
	var rows := ANIM_CONFIG.size()
	var sheet_w := MAX_COLS * FRAME_PX
	var sheet_h := rows * FRAME_PX
	var sheet := Image.create(sheet_w, sheet_h, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))

	for row in range(rows):
		for col in range(MAX_COLS):
			var key := "%d_%d" % [row, col]
			if _frame_images.has(key):
				var src: Image = _frame_images[key]
				sheet.blit_rect(src, Rect2i(0, 0, FRAME_PX, FRAME_PX), Vector2i(col * FRAME_PX, row * FRAME_PX))

	var save_err := sheet.save_png(ProjectSettings.globalize_path(OUTPUT_PATH))
	if save_err != OK:
		push_error("PixelLabSheetBuilder: failed to save sheet to %s" % OUTPUT_PATH)
	else:
		print("PixelLabSheetBuilder: sheet saved -> %s (%dx%d)" % [OUTPUT_PATH, sheet_w, sheet_h])
		print('SHEET_FRAME_COUNTS entry for Battle.gd:')
		print('"enemy_bruiser": {"idle":6,"walk":6,"melee_attack":5,"ranged_attack":4,"hit":3,"downed":6}')


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
