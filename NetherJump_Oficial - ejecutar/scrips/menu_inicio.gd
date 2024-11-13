extends CanvasLayer

func _ready():
	# Conectar señales de los botones usando Callable
	$Control/ButtonJugar.connect("pressed", Callable(self, "_on_jugar_button_pressed"))
	$Control/ButtonSalir.connect("pressed", Callable(self, "_on_salir_button_pressed"))

func _on_jugar_button_pressed():
	# Cambia a la escena principal del juego usando `change_scene_to_file`
	var scene_path = "res://scenes/main_scene.tscn"  # Asegúrate de usar la ruta correcta de tu escena principal
	var result = get_tree().change_scene_to_file(scene_path)
	if result != OK:
		print("Error: No se pudo cargar la escena en la ruta: " + scene_path)

func _on_salir_button_pressed():
	# Salir del juego
	get_tree().quit()
