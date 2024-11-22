extends Node2D

@export var move_direction: Vector2 = Vector2(0, 0)  # Vector de dirección (0, 1) para vertical, (1, 0) para horizontal
@export var move_speed: float = 50.0  # Velocidad de movimiento
@export var move_range: float = 100.0  # Rango de movimiento en píxeles

signal player_touched  # Señal que se emite cuando el jugador toca la plataforma

var initial_position: Vector2
var direction: int = 1  # 1 para moverse en la dirección inicial, -1 para la dirección opuesta
var delete_timer: Timer  # Temporizador para eliminar la plataforma después de que el jugador la toque

@onready var collision_area = $CollisionArea  # Referencia al Area2D

func _ready():
	# Guardar la posición inicial de la plataforma
	initial_position = position

	# Crear el temporizador de eliminación, pero no iniciarlo aún
	delete_timer = Timer.new()
	delete_timer.wait_time = 0.5  # Asegúrate de que este tiempo sea mayor a cero
	delete_timer.one_shot = true
	add_child(delete_timer)
	delete_timer.connect("timeout", Callable(self, "_on_timeout"))

	# Conectar la señal `body_entered` de `CollisionArea` para detectar al jugador
	if collision_area and collision_area.has_signal("body_entered"):
		collision_area.connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		push_error("Error: `CollisionArea` no se encuentra o no tiene la señal `body_entered`")

func _process(delta):
	# Si move_direction no es Vector2(0, 0), mover la plataforma
	if move_direction != Vector2(0, 0):
		position += move_direction * move_speed * direction * delta

		# Cambiar dirección si la plataforma ha alcanzado el rango de movimiento
		if (position - initial_position).length() >= move_range:
			direction *= -1  # Cambia de dirección

func _on_body_entered(body):
	# Verificar si el cuerpo que entra en contacto es el jugador
	if body.is_in_group("Player"):
		emit_signal("player_touched")  # Emitir la señal de que el jugador tocó la plataforma
		if delete_timer.wait_time > 0:
			delete_timer.start()  # Iniciar el temporizador de eliminación
		else:
			push_error("Error: `delete_timer.wait_time` debe ser mayor a cero")

func _on_timeout():
	queue_free()  # Elimina la plataforma cuando el temporizador se activa
