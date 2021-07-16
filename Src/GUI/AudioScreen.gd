extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_HSlider_value_changed(value):
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Sound"), false)
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Sound"), 
			AudioManager.volumes["Sound"] - 2*(100-value)/10.0
		)


func _on_HSlider2_value_changed(value):
	if value == 0:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Background"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Background"), false)
		AudioServer.set_bus_volume_db(
			AudioServer.get_bus_index("Background"), 
			AudioManager.volumes["Background"] - 2*(100-value)/10.0
		)


func _on_Button_pressed():	
	
	AudioManager.play_sound(AudioManager.SoundType.ButtonClick)
	Transition.fade_to("res://Src/GUI/MainMenu.tscn")

func _on_Button_mouse_entered():
	AudioManager.play_sound(AudioManager.SoundType.ButtonHover)
