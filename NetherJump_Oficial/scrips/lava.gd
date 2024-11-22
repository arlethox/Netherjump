extends Area2D

@export var base_lava_speed: float = 65.0  # Velocidad base de la lava
@export var horizontal_move_speed: float = 10.0  # Velocidad de movimiento lateral
@export var horizontal_move_range: float = 4.0  # Rango de movimiento lateral
@export var lava_speed_factor: float = 0.25  # Factor de adaptación de velocidad basado en la velocidad del jugador

@onready var lava_sprite: Sprite2D = $LavaSprite

var direction: float = 1.0  # Dirección del movimiento: 1 para derecha, -1 para izquierda
var initial_x_position: float
var is_active: bool = true  # Controla si la lava se mueve
var current_lava_speed: float  # Velocidad actual de la lava

func _ready():
	initial_x_position = lava_sprite.position.x  # Guarda la posición inicial del sprite
	current_lava_speed = base_lava_speed  # Establece la velocidad inicial de la lava

	# Conectar la señal `player_died` del jugador
	var player = get_tree().root.get_node("MainScene/Player")  # Ajusta la ruta según tu jerarquía
	player.connect("player_died", Callable(self, "_on_player_died"))

func _process(delta):
	if is_active:
		# Mover la lava hacia arriba
		position.y -= current_lava_speed * delta

		# Desplazar el sprite de lado a lado
		lava_sprite.position.x += horizontal_move_speed * delta * direction

		# Invertir la dirección si se alcanza el rango de movimiento
		if abs(lava_sprite.position.x - initial_x_position) >= horizontal_move_range:
			direction *= -1.0

# Método para actualizar la velocidad de la lava según la velocidad del jugador
func update_speed(player_speed: float):
	current_lava_speed = base_lava_speed + (player_speed * lava_speed_factor)

# Detener el movimiento de la lava cuando el jugador muera
func _on_player_died():
	is_active = false

# Método para detectar la colisión con el jugador y activar `game_over`
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):  # Asegúrate de que el jugador esté en un grupo llamado "Player"
		body.game_over()
