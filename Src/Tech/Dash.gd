extends Node


var after_dash_effect = preload("res://Src/Graphics/AfterDash.tscn")

var dir = Vector2.ZERO
var timeout = 0.0
var duration = 0.2
var speed = 400

var dup_elasped = 0.0
var dup_timeout = 0.05

var p = null

var is_active  = false

func on_action_pressed(player):
	if is_active:
		return
	p = player
	player.active_tech = self
	timeout = 0.0
	dup_elasped = 0.0
	dir = player.last_dir
	speed = player.dash_speed
	is_active = true
	duplicate_sprite(player)
	

func on_action_released():
	pass

func get_velocity() -> Vector2:
	return dir*speed
	
func invinsible() -> bool:
	return true


func _process(delta):
	if is_active:
		dup_elasped += delta
		if dup_elasped >= dup_timeout:
			dup_elasped = 0.0
			duplicate_sprite(p)
		timeout += delta
		if timeout >= duration:
			duplicate_sprite(p)
			is_active = false
			p.active_tech = null
			# Reset the velocity to stop after the dash.
			p.velocity = min(speed, p.velocity.length()) * p.velocity.normalized()
			
			
func duplicate_sprite(player):
	var sprite = player.get_node("Sprite")
	var texture_data = sprite.texture.get_data()
	
	var copy_texture = ImageTexture.new()
	copy_texture.create_from_image(texture_data)
		
	var new_sprite = after_dash_effect.instance()
	new_sprite.texture = copy_texture
	new_sprite.hframes = sprite.hframes
	new_sprite.vframes = sprite.vframes
	new_sprite.frame = sprite.frame
	player.get_parent().add_child(new_sprite)
	new_sprite.global_position = player.global_position
