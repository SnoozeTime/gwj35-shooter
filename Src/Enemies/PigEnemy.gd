extends KinematicBody2D

signal dead()

export(float) var max_speed = 35.0

var spread = 20
var speed = 0.0
var dir: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
export(float) var bullet_spread = 10.0 # + or - 10 degrees


export var health = 3

var bullet_scene = preload("res://Src/Bullets/EnemyBullet.tscn")
export var bullet_container_path := NodePath()
onready var bullet_container = get_node(bullet_container_path)

var dead_scene = preload("res://Src/Enemies/PigDead.tscn")

var shoot_min_t = 1.0
var shoot_max_t = 4.0

var player: Node2D = null

const CHAR_Z_INDEX = 2
const PISTOL_BEHIND_Z_INDEX = 1
const PISTOL_BEFORE_Z_INDEX = 3

var damage_timeout = 0.1
var damage_elapsed = 0.0

var shooting = false
export(float) var nb_shoot = 2
var shoot_done = 0
var shoot_dir = Vector2.ZERO
export(float, 1, 10) var nb_bullets = 3
export(float) var start_angle = 45.0
var bullet_angles = []

var impulse = Vector2.ZERO
var impulse_decay = 0.01

func add_impulse(p: Vector2):
	impulse += p

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	if nb_bullets <= 1:
		bullet_angles = [0.0]
	else:
		var angle_delta = (start_angle*2.0)/(nb_bullets-1)
		var current_angle = start_angle
		for i in range(nb_bullets):
			bullet_angles.append(current_angle-i*angle_delta)

	
	player = get_tree().get_nodes_in_group("Player")[0]
	randomize()
	choose_direction()

	call_deferred("initial_shoot")
	speed = max_speed
	$ComputeDirectionTimer.start(randf())

func initial_shoot():
	shoot_dir = global_position.direction_to(player.global_position).rotated(deg2rad(rand_range(-bullet_spread, bullet_spread)))
	shoot()

func _process(delta):

	
	damage_elapsed -= delta
	
	if not shooting:
		var gun_angle = global_position.angle_to_point(player.global_position)+PI
		$Gun.rotation = gun_angle
		var gun_rot_deg = $Gun.rotation_degrees
		$Gun.flip_v = gun_rot_deg < 270 and gun_rot_deg > 90

		if gun_rot_deg > 180:
			$Gun.z_index = PISTOL_BEHIND_Z_INDEX
		else:
			$Gun.z_index = PISTOL_BEFORE_Z_INDEX

func _physics_process(_delta):
	
	if is_dead():
		return
	
	
	if not shooting:
		velocity = dir * speed	
		move_and_slide(velocity+impulse)
		impulse *= impulse_decay
		
		if get_slide_count() > 0:
			var collision = get_slide_collision(get_slide_count() - 1)
			var normal = collision.normal
			dir = dir - 2 * dir.dot(normal) * normal

		$Sprite.flip_h = dir.x < 0

func choose_direction():
	dir = global_position.direction_to(player.global_position).rotated(deg2rad(rand_range(-spread, spread)))


func _on_WalkTimer_timeout():
	shooting = true
	shoot_done = 0
	shoot_dir = global_position.direction_to(player.global_position).rotated(deg2rad(rand_range(-bullet_spread, bullet_spread)))

	$AnimationPlayer.play("Idle")
	speed = 0
	$ShootTimer.start()


func _on_IdleTimer_timeout():
	shooting = false
	$AnimationPlayer.play("Walk")
	speed = max_speed
	$WalkTimer.start()


func _on_ComputeDirectionTimer_timeout():
	choose_direction()
	$ComputeDirectionTimer.start(randf())


func shoot():
	shoot_done += 1
	$ShootSound.play()

	for angle in bullet_angles:
		var dir = shoot_dir.rotated(deg2rad(angle))
		var bullet = bullet_scene.instance()
		bullet_container.add_child(bullet)
		bullet.dir  = dir
		bullet.init()
		bullet.global_position = global_position

func _on_ShootTimer_timeout():
	shoot()
	if shoot_done >= nb_shoot:
		shooting = false
		$AnimationPlayer.play("Walk")
		speed = max_speed
		$WalkTimer.start()
	else:
		$ShootTimer.start()
	
	
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
	$HitAnimationPlayer.play("Hit")

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
