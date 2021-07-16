extends Node



onready var volumes = {
	"Master": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")),
	"Background": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Background")),
	"Sound": AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Sound")),
}

enum SoundType {
	Shoot1,
	Shoot2,
	ButtonHover,
	ButtonClick,
}

onready var sounds = {
	SoundType.Shoot1: $Sounds/Shoot1,
	SoundType.Shoot2: $Sounds/Shoot2,
	SoundType.ButtonHover: $Sounds/ButtonHover,
	SoundType.ButtonClick: $Sounds/ButtonClick,
}

func play_sound(sound):
	if not sounds[sound].playing:
		sounds[sound].play()
