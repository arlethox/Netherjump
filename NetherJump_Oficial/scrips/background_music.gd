extends AudioStreamPlayer

func _ready():
	# Comenzar a reproducir automáticamente
	play()

func stop_music():
	stop()

func set_volume(new_volume: float):
	volume_db = new_volume
