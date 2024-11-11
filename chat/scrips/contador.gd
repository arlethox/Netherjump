extends CanvasLayer

@export var coin_count: int = 0  # Contador de monedas

@onready var coin_count_label: Label = $CoinCountLabel  # Ruta al Label

func _ready():
	# Conectar la señal coin_collected de la moneda
	var coin = get_node("/root/MainScene/moneda")  # Asegúrate de que la ruta sea correcta
	coin.connect("coin_collected", Callable(self, "_on_coin_collected"))
	
	# Actualizar el contador desde el inicio
	update_coin_count()

# Método que se llama cuando la señal coin_collected se emite
func _on_coin_collected():
	# Incrementar el contador de monedas cuando se recoja una
	coin_count += 1
	update_coin_count()  # Actualizar la UI

func update_coin_count():
	# Actualizar el texto del contador de monedas en la UI
	coin_count_label.text = "Monedas: " + str(coin_count)
