extends Control

export var next_scene = ""

func _process(_delta):
	
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		Transition.fade_to(next_scene)
