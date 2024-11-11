extends CanvasLayer

@export var coin_counter_label: Label  # Referencia al Label del contador
var coin_count: int = 0  # Contador de monedas

func _ready():
	# Asegúrate de conectar el Label
	coin_counter_label = $CoinCounter
	# Actualiza el texto inicial
	update_coin_counter()
	
	# Obtén una referencia a este nodo `UI` directamente
	var ui = self  # `self` se refiere al propio nodo `UI` donde está este script

	# Conecta cada moneda en el grupo "Monedas" al método add_coin en `UI`
	for moneda in get_tree().get_nodes_in_group("Monedas"):
		moneda.connect("coin_collected", Callable(ui, "add_coin"))

# Función para actualizar el contador de monedas
func update_coin_counter():
	coin_counter_label.text = "Monedas: %d" % coin_count

# Método para aumentar el contador cuando se recolecta una moneda
func add_coin():
	coin_count += 1
	update_coin_counter()
