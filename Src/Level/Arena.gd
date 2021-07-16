extends Node2D



var spawn_scene = preload("res://Src/Enemies/Spawn.tscn")
var enemy1 = preload("res://Src/Enemies/Enemy1.tscn")
var enemy2 = preload("res://Src/Enemies/PigEnemy.tscn")


var remaining_enemies = 0

func _ready():
	$NextWaveTimer.start()
	



func _on_NextWaveTimer_timeout():
	var spawn = spawn_scene.instance()
	remaining_enemies = 1
	spawn.bullet_container_path = $bullets.get_path()
	spawn.to_spawn = enemy1
	add_child(spawn)
	spawn.global_position = pick_spawn_pos()
	spawn.trigger($Player)
	

func pick_spawn_pos() -> Vector2:
	return $SpawnPos.get_child(randi() % $SpawnPos.get_child_count()).global_position
func on_enemy_death():
	remaining_enemies -= 1
	if remaining_enemies == 0:
		$NextWaveTimer.start()
