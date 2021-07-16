extends Node

var is_paused = false
var duration = 0.0
var elapsed = 0.0


func _process(delta: float) -> void:
	if is_paused:
		elapsed += delta
		if elapsed >= duration:
			is_paused = false
			get_tree().paused = false

# in sec
func pause(dt: float):
	if not is_paused:
		get_tree().paused = true
		duration = dt
		elapsed = 0.0
		is_paused = true
