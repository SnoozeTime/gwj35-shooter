extends Node2D

func _ready():
	$PayloadSwitcher.disable()

func _on_Area4_waves_finished():	
	$PayloadSwitcher.enable()
	$Ladder.enable()



func _on_Ladder_on_ladder():
	Transition.fade_to("res://Src/Level/Level3.tscn")
