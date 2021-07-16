class_name GameButton
extends Button



func _on_GameButton_mouse_entered():
	AudioManager.play_sound(AudioManager.SoundType.ButtonHover)
