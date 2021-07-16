extends Node2D

var missil_scene = preload("res://Src/Bullets/HomingBullet.tscn")

export(float) var timeout = 5.0
export(int) var missil_nb = 4
var elapsed = 0.0
var ready = true

func on_action_pressed(player):
	if ready:
		ready = false
		elapsed = 0.0
		
		var enemies = get_tree().get_nodes_in_group("Enemy")
		var enemy_nb = enemies.size()
		for _i in range(missil_nb):

			
			var missil = missil_scene.instance()
			# ACQUIRE one enemy.
			if enemy_nb > 0:
				missil.target = enemies[randi() % enemy_nb]
			missil.dir = Vector2.RIGHT.rotated(rand_range(0, 2*PI))
			player.bullet_container.add_child(missil)
			missil.global_position = player.global_position


func on_action_released():
	pass


func _process(delta):
	if not ready:
		elapsed += delta
		if elapsed >= timeout:
			ready = true
