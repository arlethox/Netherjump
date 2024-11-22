extends ParallaxBackground

@export var player_path: NodePath = "../Player"

func _process(delta):
	var player = get_node(player_path)
	if player:
		# Asegúrate de que el fondo sigue al jugador solo en el eje Y
		scroll_offset.y = player.position.y * -0.5  # Ajusta la velocidad del fondo aquí
