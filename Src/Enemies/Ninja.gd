extends KinematicBody2D

signal dead()

export(float) var max_speed = 50.0

var spread = 5
var speed = 0.0
var dir: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
export(float) var bullet_spread = 10.0 # + or - 10 degrees


export var health = 3

var dead_scene = preload("res://Src/Enemies/RabbitNinjaDead.tscn")

var shoot_min_t = 1.0
var shoot_max_t = 4.0

var player: Node2D = null

const CHAR_Z_INDEX = 2
const PISTOL_BEHIND_Z_INDEX = 1
const PISTOL_BEFORE_Z_INDEX = 3

var damage_timeout = 0.1
var damage_elapsed = 0.0


var hitting = false
var impulse = Vector2.ZERO

var impulse_decay = 0.01

func add_impulse(p: Vector2):
	impulse += p
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	speed = max_speed
	$AnimationPlayer.play("Walk")
	choose_direction()
	$ComputeDirectionTimer.start(randf())

func _process(delta):
	
	damage_elapsed -= delta
	
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= 20 and not hitting:
		$AnimationPlayer.play("Idle")
		$Sword/AnimationPlayer.play("Hit")
		hitting = true
		$ResumeAttackTimer.start()
func _physics_process(_delta):
	
	if hitting:
		return
	
	if is_dead():
		return
	
	velocity = dir * speed
	move_and_slide(velocity+impulse)
	impulse *= impulse_decay
	
	if get_slide_count() > 0:
		var collision = get_slide_collision(get_slide_count() - 1)
		var normal = collision.normal
		dir = dir - 2 * dir.dot(normal) * normal

	if dir.x < 0:
		$Sword.rotation_degrees = 180
		$Sprite.flip_h = true
	else:
		$Sword.rotation_degrees = 0
		$Sprite.flip_h = false


func choose_direction():
	dir = global_position.direction_to(player.global_position).rotated(deg2rad(rand_range(-spread, spread)))


func _on_WalkTimer_timeout():
	$AnimationPlayer.play("Idle")
	speed = 0
	$IdleTimer.start()


func _on_IdleTimer_timeout():
	$AnimationPlayer.play("Walk")
	speed = max_speed
	$WalkTimer.start()


func _on_ComputeDirectionTimer_timeout():
	choose_direction()
	$ComputeDirectionTimer.start(randf())

func is_dead():
	return health == 0
	
func hit(bullet_position: Vector2):
	if is_dead():
		return
		
	if damage_elapsed > 0:
		return

	damage_elapsed = damage_timeout
	var push_dir = bullet_position.direction_to(global_position)
	add_impulse(200*push_dir)

	health -= 1
	if is_dead():
		GamePauseTimer.pause(0.02)
		call_deferred("die", push_dir)
	else:
		
		GamePauseTimer.pause(0.01)
		
func die(dir):
	emit_signal("dead")
	var dead = dead_scene.instance()
	dead.max_speed = rand_range(300.0, 700.0)
	dead.tween_duration = rand_range(0.1, 0.4)
	get_parent().add_child(dead)
	dead.global_position = global_position
	dead.initial_dir = dir
	queue_free()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.hit(global_position)
		body.add_impulse(2000*(global_position.direction_to(body.global_position)))


func _on_ResumeAttackTimer_timeout():
	hitting = false
	$AnimationPlayer.play("Walk")
