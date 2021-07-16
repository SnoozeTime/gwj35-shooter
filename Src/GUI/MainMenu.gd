extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StoryButton_pressed():
	AudioManager.play_sound(AudioManager.SoundType.ButtonClick)
	Transition.fade_to("res://Src/GUI/Story1.tscn")



func _on_SettingButton_pressed():
	AudioManager.play_sound(AudioManager.SoundType.ButtonClick)
	Transition.fade_to("res://Src/GUI/Settings.tscn")



func _on_QuitButton_pressed():
	AudioManager.play_sound(AudioManager.SoundType.ButtonClick)
	get_tree().quit()



func _on_Button_mouse_entered():
	AudioManager.play_sound(AudioManager.SoundType.ButtonHover)


func _on_SettingButton2_pressed():
	AudioManager.play_sound(AudioManager.SoundType.ButtonClick)
	Transition.fade_to("res://Src/GUI/AudioScreen.tscn")
