extends Node2D

export(Payloads.PayloadType) var current_payload


func disable():
	$Area2D/CollisionShape2D.set_deferred("disabled", true)
	hide()

func enable():
	$Area2D/CollisionShape2D.set_deferred("disabled", false)
	show()


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.payload_switcher = self


func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		body.payload_switcher = null
