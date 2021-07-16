extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Generator.initialize()
	$Generator.iterate()
	$Generator.iterate()
#	$Generator.iterate()
#	$Generator.iterate()
	var map = $Generator.generate()
	add_child(map)
