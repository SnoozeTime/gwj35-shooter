extends KinematicBody2D


var can_move = false
var explosion_scene = preload("res://Src/Bullets/Explosion.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var dying = false
var dying_time = 0.5
	
export(float) var explosions_to_spawn_per_frame = .1
var explosion_acc = 0

func _process(delta):
	if dying:
		dying_time -= delta
		explosion_acc += explosions_to_spawn_per_frame
		var explosions_nb = int(floor(explosion_acc))
		if explosions_nb > 0:
			explosion_acc -= explosions_nb
			
			for _i in range(explosions_nb):
				
				var explosion = explosion_scene.instance()
				add_child(explosion)
				explosion.position += Vector2.LEFT.rotated(rand_range(0, 2*PI)) * rand_range(0, 10)

		if dying_time < 0:
			queue_free()

func hit(bullet_pos):
	$DamageArea/CollisionShape2D.set_deferred("disabled", false)
	dying = true


func _on_DamageArea_body_entered(body):
	if body.has_method("hit"):
		body.hit(global_position)
		if body.has_method("add_impulse"):
			body.add_impulse(global_position.direction_to(body.global_position)*5000.0)

