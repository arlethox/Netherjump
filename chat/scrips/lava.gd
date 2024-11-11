extends Area2D

@export var lava_speed := 50.0
@export var horizontal_move_speed := 30.0  # Velocidad de movimiento lateral
@export var horizontal_move_range := 10.0  # Rango de movimiento lateral

@onready var lava_sprite: Sprite2D = $LavaSprite  # Asegúrate de que el nombre del nodo sea correcto

var direction: float = 1.0  # Dirección del movimiento: 1 para derecha, -1 para izquierda
var initial_x_position: float

func _ready():
	initial_x_position = lava_sprite.position.x  # Guarda la posición inicial del sprite

func _process(delta):
	# Mover la lava hacia arriba
	position.y -= lava_speed * delta

	# Desplazar el sprite de lado a lado
	lava_sprite.position.x += horizontal_move_speed * delta * direction

	# Invertir la dirección si se alcanza el rango de movimiento
	if abs(lava_sprite.position.x - initial_x_position) >= horizontal_move_range:
		direction *= -1.0

# Método para reiniciar la escena usando call_deferred
func game_over() -> void:
	call_deferred("reload_scene")

func reload_scene() -> void:
	get_tree().reload_current_scene()

# Método único para detectar la colisión con el jugador
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):  # Asegúrate de que el jugador esté en un grupo llamado "Player"
		game_over()
