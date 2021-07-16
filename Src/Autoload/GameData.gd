extends Node


var current_game_time: float = 0.0

var actions_mapping = {
	"Action1": Payloads.PayloadType.Dash,
	"Action2": Payloads.PayloadType.HomingMissiles
}

func reset_game_time():
	current_game_time = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_game_time += delta
