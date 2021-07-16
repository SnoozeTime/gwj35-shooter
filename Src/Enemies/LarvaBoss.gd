extends KinematicBody2D

signal dead()

const BOSS_NAME = "Lava Larva"
export(float) var MAX_HEALTH = 30
var health = MAX_HEALTH
var player: Node2D = null
var spawns = []
var gatling_gun_scene = preload("res://Src/Bullets/EnemyBullet2.tscn")

var bullet_acc = 0.0
var bullet_per_frame = 0.1
var circle_bullet_per_frame = 0.04

export var bullet_container_path := NodePath()
onready var bullet_container = get_node(bullet_container_path)
var current_circle_angle = 0.0

enum BossState {
	Outside,
	Dying,
	Dead,
	Transition,
}
var state = BossState.Transition


enum ShootPattern {
	Directed,
	Circle
}
var pattern = ShootPattern.Directed
func switch_shoot_pattern():
	match pattern:
		ShootPattern.Directed:
			pattern = ShootPattern.Circle
		ShootPattern.Circle:
			pattern = ShootPattern.Directed
			
func get_bullet_per_frame() -> float:
	match pattern:
		ShootPattern.Directed:
			return bullet_per_frame
		ShootPattern.Circle:
			return circle_bullet_per_frame
	return bullet_per_frame
	
func get_bullet_directions():
	match pattern:
		ShootPattern.Circle:
			var base_dir = Vector2.LEFT.rotated(current_circle_angle)
			return [
				base_dir,
				base_dir.rotated(PI/4),
				base_dir.rotated(PI/2),
				base_dir.rotated(3*PI/4),
				base_dir.rotated(PI),
				base_dir.rotated(5*PI/4),
				base_dir.rotated(-PI/4),
				base_dir.rotated(-PI/2),
			]
	return [(global_position.direction_to(player.global_position) + player.dir).normalized()]

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	player.get_hud().set_boss_health(BOSS_NAME, health, MAX_HEALTH)
	spawns = get_tree().get_nodes_in_group("BossSpawns")
	$Sprite.hide()
	$InsideTimer.start()
	$CollisionShape2D.set_deferred("disabled", false)


func is_dead():
	return health <= 0
	
	
func _process(delta):

	current_circle_angle += PI/6
	
	
	if state == BossState.Outside:
		bullet_acc += get_bullet_per_frame()
		var bullet_nb = floor(bullet_acc)
		if bullet_nb > 0:
			bullet_acc -= bullet_nb
			# Spawn bullet in direction of player
			# BOOO cheater.
			for _i in range(bullet_nb):
				for dir in get_bullet_directions():
					shoot_bullet(dir)
				
func shoot_bullet(dir):
	#$ShootSound.play()
	$AnimationPlayer.play("Attack")
	var bullet = gatling_gun_scene.instance()
	bullet.set("target", player)
	bullet_container.add_child(bullet)
	bullet.dir = dir
	bullet.init()
	bullet.global_position = $Head.global_position


func hit(bullet_position: Vector2):
	if is_dead():
		return
		
	if state == BossState.Transition or state == BossState.Dying:
		return

	health -= 1
	player.get_hud().set_boss_health(BOSS_NAME, health, MAX_HEALTH)

	if health == 0:
		$InsideTimer.stop()
		$OutsideTimer.stop()
		call_deferred("die")

func die():
	$CollisionShape2D.disabled = true
	state = BossState.Dying
	$AnimationPlayer.play("Die")

func really_dead():
	state = BossState.Dead
	emit_signal("dead")
	player.get_hud().hide_boss()


func _on_InsideTimer_timeout():
	switch_shoot_pattern()
	if not spawns.empty():
		global_position = spawns[randi() % (spawns.size())].global_position
	
	$CollisionShape2D.set_deferred("disabled", false)
	state = BossState.Outside
	$AnimationPlayer.play("Appear")
	$OutsideTimer.start()


func _on_OutsideTimer_timeout():	

	$CollisionShape2D.set_deferred("disabled", true)
	state = BossState.Transition
	$AnimationPlayer.play("Disappear")
	$InsideTimer.start()
