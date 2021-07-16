extends Node2D


const SHIELD: bool = true

const SHIELD_HEALTH = 3.0
var health = SHIELD_HEALTH


var dead = false
var renew_duration = 5.0
var renew_elapsed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	deactivate()
	
	
func _process(delta):
	if dead:
		renew_elapsed += delta
		if renew_elapsed > renew_duration:
			dead = false
			health = SHIELD_HEALTH
		
func on_action_pressed(_player):
	activate()

func on_action_released():
	deactivate()	

func activate():
	if not dead:
		show()
		$CollisionShape2D.disabled = false

func deactivate():
	hide()
	$CollisionShape2D.disabled = true

func hit(_pos):
	
	if not dead:
		health -= 1
		if health < 0:
			modulate = Color(1, 1, 1)
			dead = true
			renew_elapsed = 0.0
			deactivate()
		else:
			modulate = Color((SHIELD_HEALTH-health)*0.3, 0, 0)
