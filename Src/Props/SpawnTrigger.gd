extends Area2D


export var to_trigger := [NodePath()]

var triggered = false


func _on_SpawnTrigger_body_entered(body):
	
	if triggered:
		return
	if body.is_in_group("Player"):
		triggered = true
		for spawn in to_trigger:
			get_node(spawn).trigger()
