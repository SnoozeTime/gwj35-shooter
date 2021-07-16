extends Sprite


var dir = Vector2.ZERO
var deaccel = 20.0
var speed = 4.0
var min_speed = 2.0
var max_speed = 5.0

var angular_speed = PI*5


func _ready():
	angular_speed = rand_range(-angular_speed, angular_speed)
	speed = rand_range(min_speed, max_speed)

func _process(delta):
	translate(speed*dir)
	speed = lerp(speed, 0.0, delta*deaccel)
	angular_speed = lerp(angular_speed, 0.0, delta*deaccel)

	rotate(angular_speed*delta)
