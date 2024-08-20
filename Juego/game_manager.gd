extends Node

var nivel: int = 1  			# Inicializa el nivel = 1
var total_niveles: int = 4
var conocimiento: int = 0		# Inicializa el conocimiento = 0
var vida_estelar: int = 3
var tiempo_juego: float = 0		# Inicializa el tiempo de juego = 0
var game_over: bool = false		# Inicializa la bandera game_over en false para iniciar el juego

func _ready() -> void:
	AudioManager.play_musica_inicio()
	
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	# Verifica si el juego ha alcanzado el nivel 5 o más, y establece game_over
	if nivel >= total_niveles:
		game_over = true
	else:
		game_over = false

# Reduce la vida_estelar
func reduce_vida_estelar():
	vida_estelar -= 1
	if vida_estelar <= 0:	
		muestra_resumen(conocimiento, tiempo_juego)
		

func resetea_vida_estelar():
	vida_estelar = 3			
	
func incrementa_conocimiento():
	conocimiento +=1
	
func resetea_inicio():
	nivel = 1			# Establece el nivel inicial del juego
	conocimiento = 0	# Establece el puntaje conocimiento inicial del jeugo
	tiempo_juego = 0	# Establece el tiempo de jeugo = 0
	game_over = false	# Establece la bandera de game over = falso			
	
func muestra_resumen(_conocimiento: int, timer_juego: float) -> void:
	if not game_over:
		conocimiento += _conocimiento
		tiempo_juego += timer_juego

		if is_inside_tree():
			var pantalla_resumen = load("res://Juego/pantalla_resumen.tscn").instantiate()
			if pantalla_resumen != null:
				#pantalla_resumen.muestra_resumen(conocimiento, tiempo_juego)
				get_tree().root.add_child(pantalla_resumen)  # Añadir la escena de resumen al árbol de nodos.
				
			else:
				print("Error: La escena 'pantalla_resumen.tscn' no se pudo cargar.")
		else:
			print("Error: El nodo principal no está disponible.")
	else:
		if is_inside_tree():
			var pantalla_fin_juego = load("res://Juego/pantalla_fin_juego.tscn").instantiate()
			get_tree().root.add_child(pantalla_fin_juego)
		else:
			print("Error: El nodo principal no está disponible.")
		
