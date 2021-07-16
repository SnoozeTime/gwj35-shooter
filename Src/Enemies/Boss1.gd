extends Node2D

signal dead()

export(float) var max_health = 1.0
var health = max_health

var player: Node2D = null


var bullet_scene = preload("res://Src/Bullets/Boss1SlowBullet.tscn")
var explosion_scene = preload("res://Src/Bullets/Explosion.tscn")
export var bullet_container_path := NodePath()
onready var bullet_container = get_node(bullet_container_path)

export(float) var explosions_to_spawn_per_frame = .4
var explosion_acc = 0



var spawn_scene = preload("res://Src/Enemies/Spawn.tscn")
var enemy1 = preload("res://Src/Enemies/Enemy1.tscn")
var enemy2 = preload("res://Src/Enemies/PigEnemy.tscn")

var hud

enum BossState {
	NotReady,
	Appearing,
	Phase1Wait,
	Phase1Shoot,
	Phase2,
	Dying,
	Dead
}
var state = BossState.NotReady

var bullet_elapsed = 0.0
var bullet_delay = 0.2
var bullet_angle = 0.0

var initial_dir = Vector2.LEFT
var bullet_rot_dir = 1
var remaining_enemies = 0



func _ready():
	$CollisionShape2D.disabled = true

func trigger(p):
	player_entered(p)

func player_entered(p):
	hud = p.get_hud()
	player = p
	state = BossState.Appearing
	$AnimationPlayer.play("Appear")
	hud.set_boss_health("Level 1 Boss", health, max_health)

func start_phase1():
	state = BossState.Phase1Wait
	bullet_elapsed = 0.0
	$Phase1WaitTimer.start()
	$CollisionShape2D.set_deferred("disabled", false)


func start_phase2():
	yield(get_tree().create_timer(2.0), "timeout")
	remaining_enemies = 4
	for d in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
		var spawn = spawn_scene.instance()
		spawn.bullet_container_path = $bullets.get_path()
		spawn.to_spawn = enemy1
		add_child(spawn)
		spawn.global_position = global_position + 150.0*d
		spawn.trigger(player)
		
func on_enemy_death():
	remaining_enemies -= 1
	if remaining_enemies == 0:
		$AnimationPlayer.play("Appear")
		start_phase1()

func _on_Phase1WaitTimer_timeout():
	state = BossState.Phase1Shoot
	bullet_rot_dir = sign(rand_range(-1.0, 1.0))
	initial_dir = global_position.direction_to(player.global_position)
	$Phase1ShootTimer.start()
	
	
func _process(delta):
	
	if state == BossState.Phase1Shoot:
		bullet_elapsed += delta
		if bullet_elapsed >= bullet_delay:
			bullet_elapsed -= bullet_delay
			# spawn bullet
			var dir = initial_dir.rotated(bullet_angle)
			shoot(dir)
			bullet_angle += bullet_rot_dir* PI / 23.0
			shoot(-dir)
			shoot(dir.rotated(PI/2))
			shoot(dir.rotated(-PI/2))
		
	if state == BossState.Dying:
		explosion_acc += explosions_to_spawn_per_frame
		var explosions_nb = int(floor(explosion_acc))
		if explosions_nb > 0:
			explosion_acc -= explosions_nb
			
			for _i in range(explosions_nb):
				
				var explosion = explosion_scene.instance()
				add_child(explosion)
				explosion.position += Vector2.LEFT.rotated(rand_range(0, 2*PI)) * rand_range(0, 40)

func shoot(dir):
	$ShootSound.play()
	var bullet = bullet_scene.instance()
	bullet_container.add_child(bullet)
	bullet.dir = dir
	bullet.init()
	bullet.global_position = global_position


func _on_Phase1ShootTimer_timeout():
	state = BossState.Phase1Wait
	$Phase1WaitTimer.start()


func hit(bullet_pos):
	health -= 1
	hud.set_boss_health("Level 1 Boss", health, max_health)

		
	if health == 0:
		$Phase1ShootTimer.stop()
		$Phase1WaitTimer.stop()
		call_deferred("die")
	elif health == int(round(max_health*0.6)) or health == int(round(max_health*0.3)):
		state = BossState.Phase2
		$Phase1ShootTimer.stop()
		$Phase1WaitTimer.stop()
		$CollisionShape2D.set_deferred("disabled", true)
		call_deferred("start_phase2")

func die():
	$AnimationPlayer.play("Die")
	$CollisionShape2D.disabled = true
	state = BossState.Dying
	
func really_dead():
	state = BossState.Dead
	emit_signal("dead")
