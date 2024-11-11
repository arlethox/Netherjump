extends CanvasLayer

@export var coin_count: int = 0  # Contador de monedas

@onready var coin_count_label: Label = $CoinCountLabel  # Asumiendo que tienes un Label en la UI

func _ready():
	# Inicializar la UI con el valor del contador de monedas
	update_coin_count()

func _on_coin_collected():
	# Incrementar el contador de monedas cuando se recoja una
	coin_count += 1
	update_coin_count()  # Actualizar la UI

func update_coin_count():
	# Actualizar el texto en la interfaz de usuario
	coin_count_label.text = "Monedas: " + str(coin_count)
