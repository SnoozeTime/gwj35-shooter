extends Node2D

func _ready():
	GameData.reset_game_time()
	$PayloadSwitcher.disable()
	tutorial()


func _on_Boss1_dead():
	$Ladder.enable()
	$PayloadSwitcher.enable()

func _on_Ladder_on_ladder():
	Transition.fade_to("res://Src/Level/Level2.tscn")



func tutorial():
	var tuto = """Move %s%s%s%s
Shoot LMC
Action 1: %s
Action 2: %s
Pause: %s
	""" % [
		OS.get_scancode_string((InputMap.get_action_list("mvt_up")[0] as InputEventKey).scancode),
		OS.get_scancode_string((InputMap.get_action_list("mvt_left")[0] as InputEventKey).scancode),
		OS.get_scancode_string((InputMap.get_action_list("mvt_down")[0] as InputEventKey).scancode),
		OS.get_scancode_string((InputMap.get_action_list("mvt_right")[0] as InputEventKey).scancode),
		OS.get_scancode_string((InputMap.get_action_list("Action1")[0] as InputEventKey).scancode),
		OS.get_scancode_string((InputMap.get_action_list("Action2")[0] as InputEventKey).scancode),
		OS.get_scancode_string((InputMap.get_action_list("Pause")[0] as InputEventKey).scancode)
	]
	
	$"Tutorial Label".text = tuto
