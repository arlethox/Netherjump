extends CharacterBody2D

const SPEED: float = 150.0
const JUMP_VELOCITY: float = -300.0
const GRAVITY: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Aplicar gravedad si no está en el suelo
	if not is_on_floor():
		velocity.y += GRAVITY * delta  # Asegúrate de tener una constante GRAVITY definida

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
	if direction != 0.0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED * delta)

	move_and_slide()

# Detectar colisión con la lava y reiniciar la escena
func _on_body_entered(body: Node) -> void:
	if body.name == "lava":
		game_over()

func _on_Lava_body_entered(body: Node) -> void:
	if body == self:
		game_over()

# Función de "Game Over" para reiniciar la escena actual
func game_over() -> void:
	get_tree().reload_current_scene()
