extends Node

const FRAME_PX := 136
const MAX_COLS := 9
const OUTPUT_PATH := "res://assets/sprites/gladiators/enemy_bruiser.png"

const ANIM_CONFIG: Array = [
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

var _pending: Array = []
var _images: Dictionary = {}
var _total := 0
var _done := 0
var _http: HTTPRequest


func _ready() -> void:
	print("SheetBuilder: starting download of %d frames..." % (ANIM_CONFIG.size() * MAX_COLS))
	for row in range(ANIM_CONFIG.size()):
		var urls: Array = ANIM_CONFIG[row][2]
		for col in range(urls.size()):
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
			img.resize(FRAME_PX, FRAME_PX, Image.INTERPOLATE_NEAREST)
			_images["%d_%d" % [job["row"], job["col"]]] = img
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
	else:
		print("SheetBuilder: ERROR saving to %s" % out)
	get_tree().quit()
