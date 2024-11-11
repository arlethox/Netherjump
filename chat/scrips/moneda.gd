extends Area2D

# Declarar la señal
signal coin_collected

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Conectar el evento body_entered a la función _on_body_entered usando Callable
	connect("body_entered", Callable(self, "_on_body_entered"))

# Método que se llama cuando el jugador entra en contacto con la moneda
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):  # Asegúrate de que el jugador esté en un grupo llamado "Player"
		emit_signal("coin_collected")  # Emitir la señal
		queue_free()  # Eliminar la moneda después de ser recogida
