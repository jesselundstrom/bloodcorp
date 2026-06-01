extends Node

const MAX_ROSTER_SIZE := 9
const STARTING_CREDITS := 1000

var credits: int = STARTING_CREDITS
var roster: Array = []
var active_sponsor = null
var current_day: int = 1


func add_gladiator(gladiator) -> bool:
	if roster.size() >= MAX_ROSTER_SIZE:
		return false
	roster.append(gladiator)
	return true


func remove_gladiator(gladiator) -> void:
	roster.erase(gladiator)


func set_sponsor(sponsor) -> void:
	active_sponsor = sponsor


func advance_day() -> void:
	current_day += 1


func reset() -> void:
	credits = STARTING_CREDITS
	roster.clear()
	active_sponsor = null
	current_day = 1
