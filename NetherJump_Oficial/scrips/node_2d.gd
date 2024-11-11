extends Node2D

# La escena de la plataforma que se instanciará
@export var platform_scene: PackedScene
@export var spawn_interval: float = 2.0  # Tiempo en segundos
var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		spawn_platform()
		timer = 0.0

func spawn_platform() -> void:
	var platform_instance = platform_scene.instantiate()
	add_child(platform_instance)
	# Posición aleatoria
	platform_instance.global_position = Vector2(randf_range(0, 400), -100)  # Ajusta los valores según el tamaño del juego
