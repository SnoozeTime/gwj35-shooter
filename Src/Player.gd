extends KinematicBody2D

export(float) var speed = 150.0
export(float) var acceleration = 10.0
export(float) var dash_speed = 400.0
export(float) var bullet_spread = 10.0 # + or - 10 degrees

var bullet_scene = preload("res://Src/Bullets/Bullet1.tscn")
var shell_scene = preload("res://Src/Props/Shell.tscn")
export var bullet_container_path := NodePath()
onready var bullet_container = get_node(bullet_container_path)


const CHAR_Z_INDEX = 2
const PISTOL_BEHIND_Z_INDEX = 1
const PISTOL_BEFORE_Z_INDEX = 3

var velocity: Vector2 = Vector2.ZERO
var dir: Vector2 = Vector2.ZERO
var last_dir: Vector2 = Vector2.ZERO

var active_tech = null

const MAX_HEALTH = 10
var health = MAX_HEALTH


onready var payload_mapping = {
	Payloads.PayloadType.Dash: $Dash,
	Payloads.PayloadType.Laser: $RotatingLaser,
	Payloads.PayloadType.HomingMissiles: $HomingMissils,
	Payloads.PayloadType.Shield: $Shield
}

enum PlayerState {
	Alive,
	Dead
}
var state = PlayerState.Alive


# If this is not null, the player will switch payloads when pressing the buttons
# Instead of executing the action.
var payload_switcher = null

func is_dead() -> bool:
	return state == PlayerState.Dead

func _process(delta):
	
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		$CanvasLayer/PauseScene.pause()
	
	if is_dead():
		return
	
	
	for k in GameData.actions_mapping:

		if payload_switcher == null:
			if Input.is_action_just_pressed(k):
				payload_mapping[GameData.actions_mapping[k]].on_action_pressed(self)
			if Input.is_action_just_released(k):
				payload_mapping[GameData.actions_mapping[k]].on_action_released()
				get_hud().activate_skill(GameData.actions_mapping[k])
		else:
			if Input.is_action_just_pressed(k):
				var old_payload = GameData.actions_mapping[k]
				GameData.actions_mapping[k] = payload_switcher.current_payload
				payload_switcher.current_payload = old_payload
				get_hud().set_skill_icons()
		
	if Input.is_action_just_pressed("Shoot"):
		shoot()

	var mouse_angle = global_position.angle_to_point(get_global_mouse_position())+PI
	
	$Gun.rotation = mouse_angle
	var gun_rot_deg = $Gun.rotation_degrees
	$Gun.flip_v = gun_rot_deg < 270 and gun_rot_deg > 90

	if gun_rot_deg > 180:
		$Gun.z_index = PISTOL_BEHIND_Z_INDEX
	else:
		$Gun.z_index = PISTOL_BEFORE_Z_INDEX
		
	var camera_offset_dir = global_position.direction_to(get_global_mouse_position())
	$Camera2D.target_offset = 80.0 * camera_offset_dir
	
func get_hud():
	return $CanvasLayer/HUD

func shoot():
	
	AudioManager.play_sound(AudioManager.SoundType.Shoot2)
	$Gun/AnimationPlayer.play("Shoot")
	$Camera2D.add_trauma(0.05)
	var bullet = bullet_scene.instance()
	bullet_container.add_child(bullet)
	bullet.dir = global_position.direction_to(get_global_mouse_position()).rotated(deg2rad(rand_range(-bullet_spread, bullet_spread)))
	
	var shell = shell_scene.instance()
	bullet_container.add_child(shell)

	shell.global_position = global_position
	if $Gun.flip_v:
		# Gun pointing to the left.
		shell.dir = Vector2(rand_range(0.0, 1.0), rand_range(0.0, 1.0)).normalized()
	else:
		shell.dir = Vector2(-rand_range(0.0, 1.0), rand_range(0.0, 1.0)).normalized()
		
	translate(-3*bullet.dir)
	bullet.init()
	bullet.global_position = $Gun/GunPoint.global_position

func _physics_process(delta):
	if is_dead():
		return

	dir = Vector2.ZERO
	
	if active_tech != null:
		velocity = active_tech.get_velocity()
	else:
		handle_inputs()
		velocity = dir*speed
	if dir != Vector2.ZERO:
		last_dir = dir
		
	
	velocity = move_and_slide(velocity)
	update_dir_and_anim()

func handle_inputs():
		
	if Input.is_action_pressed("mvt_up"):
		dir.y -= 1
	if Input.is_action_pressed("mvt_down"):
		dir.y += 1
	if Input.is_action_pressed("mvt_right"):
		dir.x += 1
	if Input.is_action_pressed("mvt_left"):
		dir.x -= 1
		
func update_dir_and_anim():
	if dir.x < 0:
		$Sprite.flip_h = true
	if dir.x > 0:
		$Sprite.flip_h = false
		
	if velocity != Vector2.ZERO:
		$AnimationPlayer.play("Walk")
		$WalkParticle.emitting = true
	else:
		$AnimationPlayer.play("Idle")
		$WalkParticle.emitting = false
		



func hit(bullet_pos: Vector2):
	if is_dead():
		return
	# Invinsibility frames
	if active_tech != null and active_tech.invinsible():
		return
	
	var push_dir = bullet_pos.direction_to(global_position)
	translate(5*push_dir)
	$Camera2D.add_trauma(.3)
		
	$HitAnimationPlayer.play("Hit")
		
	health -= 1
	$CanvasLayer/HUD.set_health(health, MAX_HEALTH)
	if health == 0:
		state = PlayerState.Dead
		var bullet_dir = bullet_pos.direction_to(global_position)
		call_deferred("death_animation", bullet_dir)
		
	
func is_invinsible():
	return active_tech != null and active_tech.invinsible()

func death_animation(bullet_dir: Vector2):
	$AnimationPlayer.play("Die")
	if bullet_dir.x > 0:
		scale.x = -1
	Engine.time_scale = 0.3
	yield(get_tree().create_timer(1), "timeout")
	Engine.time_scale = 1.0
