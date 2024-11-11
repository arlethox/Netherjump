extends Node2D

func _ready():
	# Configura un temporizador para eliminar la plataforma después de 3 segundos
	var delete_timer = Timer.new()
	delete_timer.wait_time = 3.0
	delete_timer.one_shot = true
	add_child(delete_timer)
	delete_timer.connect("timeout", Callable(self, "_on_timeout"))
	delete_timer.start()

func _on_timeout():
	queue_free()  # Elimina la plataforma cuando el temporizador se activa
