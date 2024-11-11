extends Node2D

@export var coin_counter_label: Label  # Referencia al Label que muestra el número de monedas
@export var coin_icon: TextureRect  # Referencia al TextureRect que muestra la imagen de la moneda
var coin_count: int = 0

func _ready():
	# Asegúrate de que el Label y el TextureRect estén conectados
	coin_counter_label = $Label  # Asigna el Label
	coin_icon = $TextureRect  # Asigna el TextureRect
	update_coin_counter()

# Función para actualizar el contador de monedas
func update_coin_counter():
	coin_counter_label.text = str(coin_count)  # Mostrar el número de monedas

# Método para aumentar el contador cuando se recolecta una moneda
func add_coin():
	coin_count += 1
	update_coin_counter()
