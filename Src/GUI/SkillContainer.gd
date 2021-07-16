extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var p = 0
var ready = true setget set_ready
export(Payloads.PayloadType) var payload
export var timeout = 5.0

func _process(delta):
	
	if p/timeout>1.0 and not ready:
		ready = true
		$AnimatedSprite.play("Ready")
	elif not ready:
		p += delta
		update_progress(min(1, p/timeout))
		

func update_progress(progress: float) -> void:
	# 1 means full progress
	material.set_shader_param("white_progress", 1.0 - progress)

func set_ready(r: bool):
	ready = r
	p = 0.0
