extends Sprite


# Called when the node enters the scene tree for the first time.
func _ready():
	scale *= rand_range(0.2, 1.0)


func _on_AnimationPlayer_animation_finished(anim_name):
	call_deferred("queue_free")
