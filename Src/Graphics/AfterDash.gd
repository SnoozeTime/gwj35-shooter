class_name AfterDash
extends Sprite


export(float) var life = 0.2


func _ready():
	$Tween.stop_all()
	$Tween.interpolate_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), life)
	$Tween.start()

func _process(delta):
	life -= delta
	if life < 0:
		queue_free()
