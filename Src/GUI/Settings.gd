extends Control

var currently_editing = null

onready var control_selector_container = $VBoxContainer/ControlSelectorContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	# MusicManager.play_menu()
	for c in control_selector_container.get_children():
		c.connect("start_editing", self, "_on_ControlSelector_start_editing")
		c.connect("finished_editing", self, "_on_ControlSelector_finished_editing")


func _on_ControlSelector_start_editing(control):
	
	#MusicManager.play_sound(MusicManager.SoundType.CheckboxToggle)
	if currently_editing != null:
		currently_editing.stop_editing()
		
	currently_editing = control
	control.edit()



func _on_ControlSelector_finished_editing(control):
	if currently_editing == control:
		#MusicManager.play_sound(MusicManager.SoundType.CheckboxToggle)
		currently_editing = null


func _on_Button_pressed():
	#MusicManager.play_sound(MusicManager.SoundType.ButtonClick)
	AudioManager.play_sound(AudioManager.SoundType.ButtonClick)
	if currently_editing != null:
		currently_editing.stop_editing()
	Transition.fade_to("res://Src/GUI/MainMenu.tscn")

func _on_Button_mouse_entered():
	AudioManager.play_sound(AudioManager.SoundType.ButtonHover)

