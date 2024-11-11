extends CanvasLayer

@onready var retry_button = $Button  # Referencia al botón de "Volver a Jugar"

func _ready():
	# Conectar el evento de clic del botón a la función para reiniciar el juego
	retry_button.connect("pressed", Callable(self, "_on_retry_button_pressed"))


func _on_retry_button_pressed():
	# Eliminar el nodo de Game Over de la escena
	queue_free()
	# Reiniciar la escena actual
	get_tree().reload_current_scene()
