extends Node2D


signal on_ladder()

func _ready():
	hide()


func enable():
	show()
	$Area2D/CollisionShape2D.set_deferred("disabled", false)

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("on_ladder")
