extends Node2D

export var bullet_container_path := NodePath()

export(int, 0, 3) var wave = 0
export(PackedScene) var to_spawn

func _ready():
	hide()

func trigger(_p):
	show()
	$AnimationPlayer.play("Spawn")

func _on_AnimationPlayer_animation_finished(_anim_name):
	spawn()
	
func spawn():
	var enemy = to_spawn.instance()
	enemy.set("bullet_container_path", bullet_container_path)
	get_parent().add_child(enemy)
	enemy.global_position = global_position
	enemy.connect("dead", get_parent(), "on_enemy_death")
	queue_free()
