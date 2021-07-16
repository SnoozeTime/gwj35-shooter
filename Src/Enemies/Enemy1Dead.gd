extends KinematicBody2D


var initial_dir = Vector2.ZERO
var initial_speed = 500.0
var tween_duration = 0.2
var max_speed = 500.0

func _ready():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "initial_speed", max_speed, 0.0, tween_duration)
	$Tween.start()

func _physics_process(delta):
	move_and_slide(initial_dir*initial_speed)

