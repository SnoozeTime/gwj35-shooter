extends Node2D

signal waves_finished()

export var door_path := NodePath()
onready var doors: TileMap = get_node(door_path)


var triggered = false


var door_collision_mask
var door_collision_layer

var enemies_spawned = 0
var enemies_dead = 0
var player = null

var spawns_per_wave = {
	0: [],
	1: [],
	2: [],
	3: [],
}
var current_wave = 0

func _ready():
	door_collision_layer = doors.collision_layer
	door_collision_mask = doors.collision_mask
	open_doors()
	
	
	for c in get_children():
		if c.is_in_group("Spawn"):
			if c.get("wave") != null:
				spawns_per_wave[c.wave].append(c)
			else:
				spawns_per_wave[0].append(c)

func on_area_entry(p):
	player = p
	triggered = true
	spawn_enemies(p)
	close_doors()

func spawn_enemies(p):
	enemies_spawned = 0
	
	var spawns = spawns_per_wave[current_wave]
	while spawns.empty():
		current_wave += 1
		if current_wave >= 3:
			break
		spawns = spawns_per_wave[current_wave]
	
	if spawns.empty():
		# In that case, no more waves.
		emit_signal("waves_finished")
		open_doors()
		return

	for spawn in spawns:
		spawn.trigger(p)
		enemies_spawned += 1
	
func close_doors():
	doors.show()
	doors.collision_layer = door_collision_layer
	doors.collision_mask = door_collision_mask

func open_doors():
	doors.hide()
	doors.collision_layer = 0
	doors.collision_mask = 0

func _on_Area_body_entered(body):
		
	if triggered:
		return
	if body.is_in_group("Player"):
		on_area_entry(body)

func on_enemy_death():
	enemies_spawned -= 1
	if enemies_spawned <= 0:
		current_wave += 1
		spawn_enemies(player)
