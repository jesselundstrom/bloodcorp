class_name BattleCombatEffect
extends Control

enum EffectMode { MELEE, RANGED }

var mode: EffectMode = EffectMode.MELEE
var start_pos: Vector2 = Vector2.ZERO
var end_pos: Vector2 = Vector2.ZERO
var progress: float:
	get:
		return _progress
	set(value):
		_progress = value
		queue_redraw()
var is_crit: bool = false
var _progress: float = 0.0


static func play_melee_hit(parent: Control, from_pos: Vector2, to_pos: Vector2, crit := false) -> void:
	var fx := BattleCombatEffect.new()
	fx.mode = EffectMode.MELEE
	fx.start_pos = from_pos
	fx.end_pos = to_pos
	fx.is_crit = crit
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.z_index = 28
	parent.add_child(fx)
	fx._animate(0.18)


static func play_ranged_streak(parent: Control, from_pos: Vector2, to_pos: Vector2) -> void:
	var fx := BattleCombatEffect.new()
	fx.mode = EffectMode.RANGED
	fx.start_pos = from_pos
	fx.end_pos = to_pos
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	fx.z_index = 27
	parent.add_child(fx)
	fx._animate(0.22)


func _animate(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(self, "progress", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.finished.connect(queue_free)


func _draw() -> void:
	if mode == EffectMode.RANGED:
		_draw_ranged()
	else:
		_draw_melee()


func _draw_melee() -> void:
	var center := start_pos.lerp(end_pos, 0.72)
	var dir := (end_pos - start_pos).normalized()
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
	var normal := Vector2(-dir.y, dir.x)
	var length := 26.0 if is_crit else 18.0
	var alpha := 1.0 - progress
	var color := Color(1.0, 0.18, 0.08, alpha) if is_crit else Color(1.0, 0.78, 0.35, alpha)
	draw_line(center - normal * length * 0.45, center + normal * length * 0.55, color, 3.0 if is_crit else 2.0)
	draw_line(center - dir * length * 0.35, center + dir * length * 0.35, Color(1, 1, 1, alpha * 0.55), 1.0)


func _draw_ranged() -> void:
	var alpha := 1.0 - progress
	var head := start_pos.lerp(end_pos, progress)
	var tail := start_pos.lerp(end_pos, maxf(0.0, progress - 0.24))
	draw_line(tail, head, Color(0.0, 1.0, 0.9, alpha), 3.0)
	draw_line(tail, head, Color(1.0, 1.0, 1.0, alpha * 0.5), 1.0)
