extends CharacterBody2D

const SPEED: float = 150.0
const JUMP_VELOCITY: float = -350.0
const GRAVITY: float = 900.0
signal player_died  # Señal de muerte del jugador
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer = $DeathSound  # Referencia al sonido de muerte


func _ready():
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	# Si el jugador está muriendo, no procesar movimientos
	if animated_sprite.animation == "muerte":
		return

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
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# Función de "Game Over" que reproduce la animación de muerte y luego reinicia la escena
func game_over() -> void:
	animated_sprite.play("muerte")
	velocity = Vector2.ZERO
	
	death_sound.play()
	emit_signal("player_died")
	
	# Esperar un momento antes de mostrar la pantalla de Game Over
	await get_tree().create_timer(1.5).timeout
	show_game_over_screen()

func show_game_over_screen():
	# Cargar y mostrar la pantalla de Game Over
	var game_over_scene = preload("res://scenes/game_over_screen.tscn").instantiate()
	get_tree().root.add_child(game_over_scene)
