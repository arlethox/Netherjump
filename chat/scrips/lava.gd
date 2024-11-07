extends Node2D

@export var lava_speed := 30.0

func _process(delta):
	# Mover la lava hacia arriba
	position.y -= lava_speed * delta
