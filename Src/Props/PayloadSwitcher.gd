extends Node2D

export(Payloads.PayloadType) var current_payload setget set_current_payload


export var missil_texture: Texture
export var laser_texture: Texture
export var dash_texture: Texture
export var shield_texture: Texture


func _ready():
	call_deferred("set_texture")

func set_texture():
	var payload_texture = null
	match current_payload:
		Payloads.PayloadType.Dash:
			payload_texture = dash_texture
		Payloads.PayloadType.HomingMissiles:
			payload_texture = missil_texture
		Payloads.PayloadType.Shield:
			payload_texture = shield_texture
		Payloads.PayloadType.Laser:
			payload_texture = laser_texture
	if payload_texture != null:
		$PayloadSprite.texture = payload_texture

func set_current_payload(p):
	current_payload = p
	set_texture()

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
