extends Node2D

func _ready():
	GameData.reset_game_time()
	$PayloadSwitcher.disable()


func _on_Boss1_dead():
	$Ladder.enable()
	$PayloadSwitcher.enable()

func _on_Ladder_on_ladder():
	Transition.fade_to("res://Src/Level/Level2.tscn")
