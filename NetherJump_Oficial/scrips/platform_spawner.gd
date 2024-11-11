extends Node2D

@export var platform_scene: PackedScene
@export var coin_scene: PackedScene  # Escena de la moneda
@export var spawn_area_width: float = 160.0
@export var platform_min_y_spacing: float = 30.0
@export var platform_max_y_spacing: float = 45.0
@export var spawn_interval: float = 0.5  # Intervalo de aparición en segundos
@export var delete_interval: float = 1.0  # Intervalo de eliminación en segundos
@export var spawn_chance: float = 1.0  # Probabilidad de que aparezca una moneda en una plataforma (30%)

var spawn_timer = 0.0  # Temporizador para la aparición de plataformas
var last_y = 0.0  # Altura de la última plataforma generada
var platforms_queue = []  # Cola para rastrear las plataformas generadas

func _ready():
	generate_initial_platforms()
	
	# Configura un temporizador para eliminar plataformas en el orden de aparición
	var delete_timer = Timer.new()
	delete_timer.wait_time = delete_interval
	delete_timer.one_shot = false
	add_child(delete_timer)
	delete_timer.connect("timeout", Callable(self, "_delete_oldest_platform"))
	delete_timer.start()

func _process(delta):
	# Incrementa el temporizador para generar plataformas
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_platform(Vector2(randf_range(-spawn_area_width / 2, spawn_area_width / 2), last_y))
		spawn_timer = 0.0  # Reinicia el temporizador

func generate_initial_platforms():
	# Genera algunas plataformas iniciales para comenzar
	for i in range(1):
		last_y -= randf_range(platform_min_y_spacing, platform_max_y_spacing)
		spawn_platform(Vector2(randf_range(-spawn_area_width / 2, spawn_area_width / 2), last_y))

func spawn_platform(spawn_position: Vector2):
	var platform = platform_scene.instantiate()  # Crea una instancia de la plataforma
	platform.position = spawn_position
	add_child(platform)
	
	# Añadir la plataforma a la cola para rastrear el orden de aparición
	platforms_queue.append(platform)
	
	# Posibilidad de generar una moneda en esta plataforma
	maybe_spawn_coin(platform)
	
	# Ajusta la posición para que las próximas plataformas sigan hacia arriba
	last_y -= randf_range(platform_min_y_spacing, platform_max_y_spacing)

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

func _delete_oldest_platform():
	# Verifica que haya plataformas en la cola
	if platforms_queue.size() > 0:
		# Obtiene la plataforma más antigua (la primera en la cola)
		var oldest_platform = platforms_queue.pop_front()
		
		# Verifica si la plataforma sigue existiendo antes de liberarla
		if oldest_platform and is_instance_valid(oldest_platform):
			oldest_platform.queue_free()
