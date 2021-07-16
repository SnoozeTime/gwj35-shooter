extends Control



func _on_QuitButton_pressed():
	Transition.fade_to("res://Src/GUI/MainMenu.tscn")


func _on_RestartButton_pressed():
	Transition.fade_to("res://Src/Game.tscn")

func update_and_show():
	show()
	$NinePatchRect/PlayTimeLabel.text = "Play Time: %d" % GameData.get_formatted_time()
