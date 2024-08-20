extends Node

@export var volumen_musica: float = 1.0
@export var volumen_sonido: float = 1.0

# Lista de nodos de música
var nodos_musica = []
# Lista de nodos de sonido
var nodos_sonidos = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
# Configurar los volúmenes iniciales.
	nodos_musica = [$MusicaInicio, $MusicaGalaxia]
	nodos_sonidos = [$SonidoColisionNumeroCorrecto , $SonidoColisionNumeroIncorrecto ,$SonidoColisionIgnorancia ]
	
	for musica in nodos_musica:
		musica.volume_db = linear_to_db(volumen_musica)
	
	for sonidos in nodos_sonidos:
		sonidos.volume_db = linear_to_db(volumen_sonido)

# Establece el volumen de la música
func set_volumen_musica(volumen: float) -> void:
	volumen_musica = volumen
	for musica in nodos_musica:
		musica.volume_db = linear_to_db(volumen)

# Establece el volumen de los sonidos
func set_volumen_sonido(volumen: float) -> void:
	volumen_sonido = volumen
	for sonido in nodos_sonidos:
		sonido.volume_db = linear_to_db(volumen)

# Cambia a mute de la música
func toggle_mute_musica() -> void:
	for musica in nodos_musica:
		if musica.volume_db > -80:
			musica.volume_db = -80
		else:
			musica.volume_db = linear_to_db(volumen_musica)

# Cambia a mute de los sonidos
func toggle_mute_sonido() -> void:
	for sonido in nodos_sonidos:
		if sonido.volume_db > -80:
			sonido.volume_db = -80
		else:
			sonido.volume_db = linear_to_db(volumen_sonido)

# PLay o Stop de Musica_Inicio
func play_musica_inicio() -> void:
	#set_volumen_musica(-2)
	$MusicaInicio.play()
func stop_musica_inicio():
	$MusicaInicio.stop()
# Play o Stop de Musica_Galacia	
func play_musica_galaxia() -> void:
	$MusicaGalaxia.play()
func stop_musica_galaxia() -> void:
	$MusicaGalaxia.stop()
# Play o Stop de Sonido_colisiona_numero_correcto
func play_sonido_colision_numero_correcto() -> void:
	$SonidoColisionNumeroCorrecto.play()
func stop_sonido_colision_numero_correcto() -> void:
	$SonidoColisionNumeroCorrecto.stop()
# Play o Stop de Sonido_colisiona_numero_incorrecto
func play_sonido_colision_numero_incorrecto() -> void:
	$SonidoColisionNumeroIncorrecto.play()
func stop_sonido_colision_numero_incorrecto() -> void:
	$SonidoColisionNumeroIncorrecto.stop()
# Play o Stop de Sonido_colisiona_ignorancia	
func play_sonido_colision_ignorancia() -> void:
	$SonidoColisionIgnorancia.play()
func stop_sonido_colision_ignorancia() -> void:
	$SonidoColisionIgnorancia.stop()
