extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


enum SoundType {
	Shoot1,
	Shoot2
}

onready var sounds = {
	SoundType.Shoot1: $Sounds/Shoot1,
	SoundType.Shoot2: $Sounds/Shoot2,
}

func play_sound(sound):
	sounds[sound].play()
