extends Node2D

var is_casting := false setget set_is_casting

var nb_rotation = 2
var timeout = nb_rotation # 2 per sec
var elapsed = 0

var reload_timeout = 4.0
var reload_elapsed = 0.0

func on_action_pressed(player):
	if can_use():
		set_is_casting(true)


func on_action_released():
	if can_use():
		set_is_casting(false)



# Called when the node enters the scene tree for the first time.
func _ready():
	set_physics_process(false)


func can_use():
	return reload_elapsed < 0

func set_is_casting(cast: bool) -> void:
	is_casting = cast
	$CastingParticles2D.emitting = cast
	$RayCast2D/Line2D.visible = cast

	if is_casting:
		elapsed = 0
		appear()
	else:
		reload_elapsed = reload_timeout
		$CollisionParticles2D.emitting = false
		disappear()
	set_physics_process(is_casting)

func _physics_process(delta: float) -> void:
	
	$RayCast2D.cast_to= $RayCast2D.cast_to.rotated(delta * 2*PI)
	
	var cast_point = $RayCast2D.cast_to
	
	$CastingParticles2D.global_rotation = cast_point.angle()
	$RayCast2D.force_raycast_update()
	if $RayCast2D.is_colliding():
		$CollisionParticles2D.emitting = $RayCast2D.is_colliding()
		cast_point = to_local($RayCast2D.get_collision_point())
		$CollisionParticles2D.global_rotation = $RayCast2D.get_collision_normal().angle()
		$CollisionParticles2D.global_position = $RayCast2D.get_collision_point()
		
		if $RayCast2D.get_collider().has_method("hit"):
			$RayCast2D.get_collider().hit(global_position)
	
	
	$RayCast2D/Line2D.points[1] = cast_point

func appear() -> void:
	$RayCast2D/Tween.stop_all()
	$RayCast2D/Tween.interpolate_property($RayCast2D/Line2D, "width", 0, 4.0, 0.2)
	$RayCast2D/Tween.start()
	

func disappear() -> void:
	$RayCast2D/Tween.stop_all()
	$RayCast2D/Tween.interpolate_property($RayCast2D/Line2D, "width", 4.0, 0.0, 0.1)
	$RayCast2D/Tween.start()

func _process(delta):
	
	reload_elapsed -= delta
	if is_casting:
		elapsed += delta
		if elapsed > timeout:
			set_is_casting(false)

