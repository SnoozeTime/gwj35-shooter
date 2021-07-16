extends KinematicBody2D

signal dead()

export(float) var MAX_HEALTH = 30
var health = MAX_HEALTH
var phase2_health = floor(MAX_HEALTH/2.0)

var gatling_gun_scene = preload("res://Src/Bullets/EnemyBullet2.tscn")
var bazooka_gun_scene = preload("res://Src/Bullets/Rocket.tscn")
export var bullet_container_path := NodePath()
onready var bullet_container = get_node(bullet_container_path)

var walk_anim = "WalkClothes"
var idle_anim = "Idle"
var starting_phase2 = false

export(float) var max_speed = 50.0

var spread = 10
var speed = max_speed
var dir: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

onready var current_gun = $Gatling
const CHAR_Z_INDEX = 2
const PISTOL_BEHIND_Z_INDEX = 1
const PISTOL_BEFORE_Z_INDEX = 3


var gatling_acc = 0.0
var bullet_per_frame = 0.1
var is_shooting = true


func get_bullet_per_frame():
	if state == BossState.Phase1:
		return 0.1
	else:
		return 0.03

enum BossState {
	Phase1,
	Transition,
	Phase2,
	Dying
	Dead
}
var state = BossState.Phase1

var player: Node2D = null
# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	player.get_hud().set_boss_health("Pig Boss", health, MAX_HEALTH)
	choose_direction()
	
	$Gatling.show()
	$Bazooka.hide()
	
	$Phase1ShootTimer.start()

	
func _physics_process(delta):
	if is_dead():
		return
		
	if state == BossState.Transition or state == BossState.Dying:
		return
	
	velocity = dir * speed
	move_and_slide(velocity)
	
	if get_slide_count() > 0:
		var collision = get_slide_collision(get_slide_count() - 1)
		var normal = collision.normal
		dir = dir - 2 * dir.dot(normal) * normal

	$Sprite.flip_h = dir.x < 0
	$AnimationPlayer.play(idle_anim)
	

	
func _process(delta):
	var gun_angle = global_position.angle_to_point(player.global_position)+PI
	
	current_gun.rotation = gun_angle
	var gun_rot_deg = current_gun.rotation_degrees
	current_gun.flip_v = gun_rot_deg < 270 and gun_rot_deg > 90

	if gun_rot_deg > 180:
		current_gun.z_index = PISTOL_BEHIND_Z_INDEX
	else:
		current_gun.z_index = PISTOL_BEFORE_Z_INDEX
		
		
	# HOW TO SHOOT
	# ----------------------------------------------

	if state == BossState.Phase1 or state == BossState.Phase2:
		if is_shooting:
			gatling_acc += get_bullet_per_frame()
			var bullet_nb = floor(gatling_acc)
			if bullet_nb > 0:
				gatling_acc -= bullet_nb
				
				# Spawn bullet in direction of player
				# BOOO cheater.
				for _i in range(bullet_nb):
					shoot_bullet((global_position.direction_to(player.global_position) + player.dir).normalized())


func get_bullet_scene():
	if state == BossState.Phase1:
		return gatling_gun_scene
	else:
		return bazooka_gun_scene

func shoot_bullet(dir):
	#$ShootSound.play()
	var bullet = get_bullet_scene().instance()
	bullet.set("target", player)
	bullet_container.add_child(bullet)
	bullet.dir = dir
	bullet.init()
	bullet.global_position = current_gun.get_node("Head").global_position

func is_dead():
	return health <= 0
	
func trigger_phase2():
	$Gatling.hide()
	$Bazooka.hide()
	state = BossState.Transition
	$AnimationPlayer.play("RipShirt")
	
func start_phase2():
	state = BossState.Phase2

	walk_anim = "WalkNaked"
	idle_anim = "IdleNaked"
	
	current_gun = $Bazooka
	$Bazooka.show()
	
func hit(bullet_position: Vector2):
	if is_dead():
		return
		
	if state == BossState.Transition or state == BossState.Dying:
		return

	health -= 1
	player.get_hud().set_boss_health("Pig Boss", health, MAX_HEALTH)
	
	if health == phase2_health:
		call_deferred("trigger_phase2")
	elif health == 0:
		$Phase1ShootTimer.stop()
		$Phase1WaitTimer.stop()
		call_deferred("die")

func die():
	# $AnimationPlayer.play("Die")
	$CollisionShape2D.disabled = true
	state = BossState.Dying
	current_gun.hide()
	$AnimationPlayer.play("Die")

func really_dead():
	state = BossState.Dead
	emit_signal("dead")


func _on_ComputeDirectionTimer_timeout():
	choose_direction()

	
func choose_direction():
	dir = global_position.direction_to(player.global_position).rotated(deg2rad(rand_range(-spread, spread)))


func _on_Phase1ShootTimer_timeout():
	is_shooting = false
	$Phase1WaitTimer.start()


func _on_Phase1WaitTimer_timeout():	
	is_shooting = true
	$Phase1ShootTimer.start()
