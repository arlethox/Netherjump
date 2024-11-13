extends Node2D

@export var platform_scene: PackedScene
@export var coin_scene: PackedScene  # Escena de la moneda
@export var player_path: NodePath = "../Player"  # Ruta al nodo del jugador

# DISTANCIA Y ÁREA DE GENERACIÓN
@export var platform_min_y_spacing: float = 65.0
@export var platform_max_y_spacing: float = 70.0
@export var max_horizontal_distance: float = 85.0  # Máxima distancia permitida en el eje X entre plataformas
@export var min_horizontal_spacing: float = 84.9  # Distancia mínima horizontal entre plataformas
@export var spawn_area_width: float = 195.0

# SPAWNING
@export var spawn_interval: float = 0.1  # Intervalo de aparición en segundos
@export var spawn_chance: float = 1.0  # Probabilidad de que aparezca una moneda en una plataforma
@export var mobile_platform_chance: float = 0.5  # Probabilidad de crear una plataforma móvil adicional

@export var jump_height: float = 100.0  # Ajusta según el salto máximo del jugador

var spawn_timer = 0.0  # Temporizador para la aparición de plataformas
var last_y = 0.0  # Altura de la última plataforma generada
var last_x = 0.0  # Posición X de la última plataforma generada
var platforms_queue = []  # Cola para rastrear las plataformas generadas

func _ready():
	generate_initial_platforms()

func _process(delta):
	# Incrementa el temporizador para generar plataformas
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		# Generar una plataforma en un rango adecuado
		var new_x = last_x
		while abs(new_x - last_x) < min_horizontal_spacing:
			new_x = clamp(randf_range(last_x - max_horizontal_distance, last_x + max_horizontal_distance), -spawn_area_width / 2, spawn_area_width / 2)
		
		var new_position = Vector2(new_x, last_y)
		
		if can_spawn_platform_at(new_position):
			spawn_platform(new_position)
			# Posibilidad de generar una plataforma móvil adicional
			if randf() < mobile_platform_chance:
				spawn_mobile_platform(Vector2(randf_range(-spawn_area_width / 2, spawn_area_width / 2), last_y - 10))
			spawn_timer = 0.0  # Reinicia el temporizador

func generate_initial_platforms():
	# Obtener al jugador para usar su posición
	var player = get_node(player_path)
	var player_position = player.position

	# Generar plataformas cercanas al jugador
	var spawn_position = Vector2()  # Declarar spawn_position fuera del bucle
	for i in range(3):  # Genera algunas plataformas iniciales
		var offset_y = i * platform_min_y_spacing  # Distancia vertical entre plataformas iniciales
		var new_x = clamp(randf_range(player_position.x - max_horizontal_distance, player_position.x + max_horizontal_distance), -spawn_area_width / 2, spawn_area_width / 2)
		spawn_position = Vector2(new_x, player_position.y - offset_y)
		spawn_platform(spawn_position)

	# Ajusta `last_y` y `last_x` para futuras plataformas
	last_y = spawn_position.y - randf_range(platform_min_y_spacing, platform_max_y_spacing)
	last_x = spawn_position.x

func spawn_platform(spawn_position: Vector2):
	var platform = platform_scene.instantiate()  # Crea una instancia de la plataforma
	platform.position = spawn_position
	add_child(platform)
	
	# Añadir la plataforma a la cola para rastrear el orden de aparición
	platforms_queue.append(platform)
	
	# Conectar la señal `player_touched` para iniciar un temporizador de eliminación
	platform.connect("player_touched", Callable(self, "_on_player_touched_platform").bind(platform))
	
	# Posibilidad de generar una moneda en esta plataforma
	maybe_spawn_coin(platform)
	
	# Actualizar la última posición X y Y para futuras plataformas
	last_y -= randf_range(platform_min_y_spacing, platform_max_y_spacing)
	last_x = spawn_position.x
	
func _on_player_touched_platform(platform):
	# Configura un temporizador para eliminar la plataforma 3 segundos después de que el jugador la toque
	var delete_timer = Timer.new()
	delete_timer.wait_time = 3.0  # Configurado a 3 segundos
	delete_timer.one_shot = true
	platform.add_child(delete_timer)
	delete_timer.connect("timeout", Callable(platform, "queue_free"))
	delete_timer.start()
	
func spawn_mobile_platform(spawn_position: Vector2):
	var platform = platform_scene.instantiate()  # Crea una instancia de la plataforma
	platform.position = spawn_position
	add_child(platform)
	
	# Configuración de movimiento aleatorio
	platform.move_direction = Vector2(1, 0) if randf() < 0.5 else Vector2(0, -1)  # Solo permite movimiento hacia arriba si es vertical
	platform.move_speed = 50 + randf() * 100  # Velocidad entre 50 y 150
	platform.move_range = 50 + randf() * 150  # Rango entre 50 y 200

	# Añadir la plataforma móvil a la cola para su eliminación controlada
	platforms_queue.append(platform)

func maybe_spawn_coin(platform: Node2D):
	# Genera un número aleatorio para decidir si aparece una moneda
	if randf() < spawn_chance:
		var coin = coin_scene.instantiate()  # Crea una instancia de la moneda
		# Coloca la moneda justo encima de la plataforma
		coin.position = platform.position + Vector2(0, -10)  # Ajusta la posición según el tamaño de la moneda
		add_child(coin)

		# Conectar la señal `coin_collected` de la moneda al `add_coin` del CoinCounter en UI
		var ui = get_tree().root.get_node("MainScene/UI")  # Ajusta la ruta según tu jerarquía
		coin.connect("coin_collected", Callable(ui, "add_coin"))

func can_spawn_platform_at(position: Vector2) -> bool:
	# Verificar que la nueva plataforma no esté demasiado cerca de las existentes
	for platform in platforms_queue:
		# Asegurarse de que la plataforma es válida antes de acceder a su posición
		if is_instance_valid(platform) and position.distance_to(platform.position) < platform_min_y_spacing:
			return false
	return true
