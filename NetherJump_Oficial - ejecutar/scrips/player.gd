extends CharacterBody2D

const BASE_SPEED: float = 150.0
const SPEED_INCREMENT: float = 5.0  # Incremento de velocidad
const HEIGHT_THRESHOLD: float = 100.0  # Altura a la que se incrementa la velocidad
const JUMP_VELOCITY: float = -350.0
const GRAVITY: float = 900.0
signal player_died  # Señal de muerte del jugador

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer = $DeathSound
@onready var game_over_scene := preload("res://scenes/game_over_screen.tscn")  # Preload de la escena de Game Over
@onready var background_music := get_tree().root.get_node("MainScene/BackgroundMusic")  # Ruta al nodo de la música de fondo

var current_speed: float = BASE_SPEED  # Velocidad actual del jugador
var max_height_reached: float = 0.0  # Altura máxima alcanzada por el jugador

func _ready():
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	# Si el jugador está muriendo, no procesar movimientos
	if animated_sprite.animation == "muerte":
		return

	# Incrementar la velocidad según la altura alcanzada
	if position.y < max_height_reached - HEIGHT_THRESHOLD:
		current_speed += SPEED_INCREMENT
		max_height_reached = position.y
		
		# Notificar a la lava para que ajuste su velocidad
		var lava = get_tree().root.get_node("MainScene/Lava")  # Ajusta la ruta a la lava si es necesario
		if lava:
			lava.update_speed(current_speed)

	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Manejar el salto
	if Input.is_action_just_pressed("salto") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Obtener la dirección de entrada y manejar el movimiento
	var direction := Input.get_axis("mover_izq", "mover_der")

	# Configurar la animación del sprite según la dirección
	if direction < 0:
		animated_sprite.flip_h = true
	elif direction > 0:
		animated_sprite.flip_h = false

	# Reproducir las animaciones según el estado
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("mover")
	else:
		animated_sprite.play("salto")

	# Aplicar movimiento
	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)

	move_and_slide()

# Función de "Game Over" que reproduce la animación de muerte y luego reinicia la escena
func game_over() -> void:
	animated_sprite.play("muerte")
	velocity = Vector2.ZERO
	
	death_sound.play()
	emit_signal("player_died")
	
	# Instanciar la escena de Game Over
	var game_over_instance = game_over_scene.instantiate()
	get_tree().root.add_child(game_over_instance)

	# Acceder al FadeOverlay dentro de la instancia de Game Over
	var fade_overlay = game_over_instance.get_node("FadeOverlay")  # Ajusta la ruta si es necesario
	fade_overlay.visible = true
	fade_overlay.modulate.a = 0  # Empezar desde transparencia total

	# Crear el efecto de fundido en el ColorRect usando un Tweener
	var tweener = get_tree().create_tween()
	tweener.tween_property(
		fade_overlay,          # Nodo que queremos animar
		"modulate:a",          # Propiedad de opacidad del color
		1.0,                   # Valor final (opaco)
		1.5                    # Duración de la transición en segundos
	)

	# Esperar a que el fundido termine antes de finalizar la animación (si es necesario)
	await tweener.finished
