extends Node2D

var dir = Vector2.LEFT
export(float) var speed = 5

export var player_bullet = true

var target: Node2D = null

func init():
	rotation = dir.angle()

func _physics_process(delta):
	translate(dir*speed)

	# Update the dir so that the bullet is going towards the target.
	if target != null:
		dir += (global_position+dir).direction_to(target.global_position)*0.1
		dir = dir.normalized()
	rotation = dir.angle()

func _on_Area2D_body_entered(body):

	# Case where the bullet goes through
	if player_bullet and (body.is_in_group("PlayerShield") or body.is_in_group("Player")):
		return
	if not player_bullet and body.is_in_group("Enemy"):
		return
		
	if not player_bullet and body.is_in_group("Player") and body.is_invinsible():
		return

	speed = 0
	
	if body.has_method("hit"):
		body.hit(global_position)
	
	call_deferred("init_remove")

func init_remove():
	$Area2D/CollisionShape2D.disabled = true
	$AnimationPlayer.play("Impact")


func remove():
	
	call_deferred("queue_free")
