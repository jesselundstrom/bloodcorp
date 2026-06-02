extends Node

const MAX_ROSTER_SIZE := 9
const MAX_INJURIES := 3
const STARTING_CREDITS := 1000
const SAVE_PATH := "user://savegame.json"

var credits: int = STARTING_CREDITS
var roster: Array = []
var active_sponsor: Dictionary = {}
var current_day: int = 1

# Sponsor dict schema:
# { "name": String, "flavor": String, "requirement_kills": int, "reward": int, "penalty": int }


func add_gladiator(gladiator) -> bool:
	if roster.size() >= MAX_ROSTER_SIZE:
		return false
	roster.append(gladiator)
	return true


func remove_gladiator(gladiator) -> void:
	roster.erase(gladiator)


func kill_gladiator(index: int) -> void:
	if index >= 0 and index < roster.size():
		roster.remove_at(index)


func apply_injury(index: int, injury_key: String, recovery_multiplier: int = 1) -> void:
	if index < 0 or index >= roster.size():
		return
	var g: Dictionary = roster[index]
	if not g.has("injuries"):
		g["injuries"] = []
	if g["injuries"].size() >= MAX_INJURIES:
		# TODO: cap exceeded — spike death chance when career stage system exists
		return
	var recovery: int = InjuryData.INJURIES[injury_key]["recovery_matches"] * recovery_multiplier
	g["injuries"].append({"key": injury_key, "remaining": recovery})


func tick_injuries() -> void:
	for g in roster:
		if not g.has("injuries"):
			continue
		var kept: Array = []
		for inj in g["injuries"]:
			inj["remaining"] -= 1
			if inj["remaining"] > 0:
				kept.append(inj)
		g["injuries"] = kept


func heal_injury_immediate(roster_index: int, injury_index: int) -> void:
	# TODO: med bay — deduct credits, remove injury, refresh Management UI
	if roster_index < 0 or roster_index >= roster.size():
		return
	var g: Dictionary = roster[roster_index]
	if not g.has("injuries") or injury_index < 0 or injury_index >= g["injuries"].size():
		return
	g["injuries"].remove_at(injury_index)


func set_sponsor(sponsor: Dictionary) -> void:
	active_sponsor = sponsor


func advance_day() -> void:
	current_day += 1


func reset() -> void:
	credits = STARTING_CREDITS
	roster.clear()
	active_sponsor = {}
	current_day = 1


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func save_game() -> void:
	var data := {
		"credits": credits,
		"current_day": current_day,
		"roster": roster.duplicate(true),
		"active_sponsor": active_sponsor.duplicate(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return false
	credits = int(parsed.get("credits", STARTING_CREDITS))
	current_day = int(parsed.get("current_day", 1))
	var saved_roster = parsed.get("roster", [])
	roster.clear()
	if saved_roster is Array:
		for entry in saved_roster:
			if entry is Dictionary:
				for stat in ["strength_score", "dexterity", "constitution", "intelligence", "charisma"]:
					if not entry.has(stat):
						entry[stat] = 10
				if not entry.has("injuries"):
					entry["injuries"] = []
				roster.append(entry)
	var saved_sponsor = parsed.get("active_sponsor", {})
	active_sponsor = saved_sponsor if saved_sponsor is Dictionary else {}
	return true
