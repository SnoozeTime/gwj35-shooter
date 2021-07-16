extends Node2D

var dir = Vector2.LEFT
export(GameConfig.BulletType) var bullet_type
export var player_bullet = true
onready var speed = GameConfig.get_bullet_speed(bullet_type)

func init():
	rotation = dir.angle()
	
func _physics_process(delta):
	translate(dir*speed)


func _on_Area2D_body_entered(body):

	# Case where the bullet goes through
	if player_bullet and (body.is_in_group("PlayerShield") or body.is_in_group("Player")):
		return
	if not player_bullet and (body.is_in_group("Enemy") or body.is_in_group("Destructible")):
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
