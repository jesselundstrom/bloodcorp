@tool
extends EditorScript

# PixelLabSheetBuilder - assembles PixelLab animation frame URLs into a sprite sheet.
#
# USAGE: Open this script in the Godot Script editor, then File > Run (Ctrl+Shift+X).
# Downloads each frame from PixelLab and stitches them into OUTPUT_PATH.
#
# Sheet layout: 6 rows (one per animation state), MAX_COLS columns.
# Frame size: FRAME_PX x FRAME_PX per cell. Short rows are transparent-padded on the right.

const FRAME_PX := 136           # PixelLab output size for this character (136x136)
const MAX_COLS := 9             # all animations are 9 frames

const OUTPUT_PATH := "res://assets/sprites/gladiators/enemy_bruiser.png"

# Row order must match ANIM_ROWS in BattleUnitVisual.gd:
#   idle=0, walk=1, melee_attack=2, ranged_attack=3, hit=4, downed=5
const ANIM_CONFIG: Array = [
	# [row_name, frame_count, [url0..url8]]
	["idle", 9, [
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
	["walk", 9, [
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
	["melee_attack", 9, [
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
	["ranged_attack", 9, [
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
	["hit", 9, [
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
	["downed", 9, [
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
		var urls: Array = entry[2]
		for col in range(urls.size()):
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
			img.resize(FRAME_PX, FRAME_PX, Image.INTERPOLATE_NEAREST)
			_frame_images["%d_%d" % [job["row"], job["col"]]] = img
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
		print('"enemy_bruiser": {"idle":9,"walk":9,"melee_attack":9,"ranged_attack":9,"hit":9,"downed":9}')
