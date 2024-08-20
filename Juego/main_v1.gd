extends Node

@export var ignorancia_escena: PackedScene
@export var numero_escena: PackedScene

var conocimiento: int = 0
var activa_ignorancia:bool = true	# Variable bool que activa la instancia de ignorancia
var activa_numero:bool = true		# Variable bool que activa la instancia de numero
var ecuacion_actual: String = ""	# Variable string para armar la ecuación
var operador_1: int					# Variable entera operador_1 de la ecuación
var operador_2: int					# Variable entera operador_2 de la ecuación
var resultado_esperado: int			# Variable entera resultado_esperado de la ecuación
var espera_nueva_ecuacion: bool = false		# Variable bool que avisa por una nueva ecuación
var ecuaciones_restantes: int = 2
var timer_juego: float
var numeros_generados: int = 0
var opciones = []
#var nivel_terminado:bool = false			# Variable bool que avisa si el juego terminó

func _ready():
	nuevo_game()

func nuevo_game():
	# Limpia pantalla de numeros e ignorancia
	get_tree().call_group("Ignorancia", "queue_free")
	get_tree().call_group("Numero", "queue_free")
	
	conocimiento = 0
	timer_juego = 0.0
	numeros_generados = 0
		
	$Astronauta.start($PosicionInicialAstronauta.position)
	
	$TimerInicio.start()	
	
	$HUD.acualiza_conocimiento(conocimiento)
	$HUD.muestra_ecuacion("Estás listo?")
	
	$Musica.play()
	
func game_over():
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
	$TimerEsperaEcuacion.stop()
	
	$HUD.muestra_game_over()
	
	$Musica.stop()
	$SonidoGameOver.play()
	mostrar_resumen()

	
func _process(delta):
	timer_juego += delta
	
	
func _on_timer_inicio_timeout():
	#print("inicia el juego")
	generar_nueva_ecuacion()
	
func _on_timer_ignorancia_timeout() -> void:
	if activa_ignorancia:
		adiciona_ignorancia()
		
func _on_timer_numero_timeout():
	if activa_numero:
		adicionar_numero(opciones[numeros_generados])
	
func _on_timer_espera_ecuacion_timeout() -> void:
	if espera_nueva_ecuacion:
		espera_nueva_ecuacion = false
		if ecuaciones_restantes > 0:
			generar_nueva_ecuacion()
		else:
			mostrar_resumen()
	else:
		if numeros_generados < opciones.size():
			$TimerNumero.start()
			#adicionar_numero(opciones[numeros_generados])
			numeros_generados += 1
		else:
			$TimerEsperaEcuacion.stop()
			$TimerNumero.stop()
			$TimerIgnorancia.stop()
	
func generar_nueva_ecuacion() -> void:
	if ecuaciones_restantes > 0:
		operador_1 = randi_range(1, 10)
		operador_2 = randi_range(1, 10)
		ecuacion_actual = str(operador_1) + " + " + str(operador_2) + " = ?"
		resultado_esperado = operador_1 + operador_2
		$HUD.muestra_ecuacion(ecuacion_actual)
		# Limpia la devolución anterior del HUD
		$HUD.muestra_devolucion("", Color.WHITE)
		generar_opciones(resultado_esperado)
		numeros_generados = 0
		ecuaciones_restantes -= 1
		activa_ignorancia = true
		activa_numero = true
		
	else:
		game_over()
		#call_deferred("mostrar_resumen")
		
func generar_opciones(resultado_correcto: int) -> void:
	opciones = []
	opciones.append(resultado_correcto)
	
	for i in range(4):
		var opcion = resultado_correcto + (i - 2)  # Genera opciones cercanas al resultado
		if opcion not in opciones and opcion > 0:
			opciones.append(opcion)
	
	opciones.shuffle()

func adiciona_ignorancia():
	# Crea una instancia de ignorancia en la escena
	var ignorancia = ignorancia_escena.instantiate()
	# Elige una posición aleatoria de la escena sobre Path2D.
	var posicion_ignorancia = get_node("PathIgnorancia/PosicionIgnorancia")
	posicion_ignorancia.progress = randi()
	#var posicion_ignorancia = $PathIgnorancia/PosicionIgnorancia
	#posicion_ignorancia.progress_ratio = randf()
	# Define una dirección perpendicular de ignorancia en el path
	var direction = posicion_ignorancia.rotation + PI / 2
	# Define la posición aleatoria de inicio de ignorancia
	ignorancia.position = posicion_ignorancia.position
	# Define una dirección de movimiento aletoria de ignorancia
	direction += randf_range(-PI / 4, PI / 4)
	ignorancia.rotation = direction
	# Define la velocidad de ignorancia en forma aleaoria
	var min_velocidad = ignorancia.min_velocidad
	var max_velocidad = ignorancia.max_velocidad
	var velocity = Vector2(randf_range(min_velocidad, max_velocidad), 0.0)
	ignorancia.linear_velocity = velocity.rotated(direction)
	# Genera ignorancia en la escena Main
	add_child(ignorancia)
	
func adicionar_numero(valor: int) -> void:
	# Create a Mob instance and add it to the scene.
	var numero = numero_escena.instantiate()
	# Elige una posición aleatoria de la escena sobre Path2D.
	var posicion_numero = get_node("PathNumero/PosicionNumero")
	posicion_numero.progress = randi()
	# Define una dirección perpendicular del numero en el path
	var direction = posicion_numero.rotation + PI / 2
	#Define la posición aleatoria de inicio de ignorancia
	numero.position = posicion_numero.position
	# Define una dirección de movimiento aletoria de numero
	#direction += randf_range(-PI / 4.0 , PI / 4.0)
	#numero.rotation = direction	
	# Define la velocidad de numero en forma aleaoria
	var max_velocidad = numero.max_velocidad
	var min_velocidad = numero.min_velocidad
	var velocity = Vector2(randf_range(min_velocidad, max_velocidad), 0.0).rotated(direction)
	numero.linear_velocity = velocity
		
	numero.muestra_numero(str(valor))
	# Genera numero en la escena Main
	add_child(numero)
		
func _on_astronauta_hit(numero: int) -> void:
	if numero == resultado_esperado:
		conocimiento += 1
		$HUD.acualiza_conocimiento(conocimiento)
		# Mostrar la ecuación completa en el HUD
		$HUD.muestra_ecuacion(str(operador_1) + " + " + str(operador_2) + " = " + str(resultado_esperado))
		
		# Mostrar un mensaje de devolución
		despues_de_colision("bien resuelto", Color.GREEN)	
	else:
		despues_de_colision("no resolviste", Color.RED)

func _on_astronauta_colisiono_con_ignorancia() -> void:
	despues_de_colision("te atraparon", Color.RED)
	
func despues_de_colision(mensaje, color: Color):
	# Limpiar todos los enemigos (ignorancia y números) en pantalla
	get_tree().call_group("Ignorancia", "queue_free")
	get_tree().call_group("Numero", "queue_free")
	
	# Mostrar un mensaje de devolución
	$HUD.muestra_devolucion(mensaje, color)
	
	# Iniciar el TimerEsperaEcuacion para esperar 2 segundos
	$TimerEsperaEcuacion.start(5)
	
	# Establecer una bandera o variable para indicar que se debe generar una nueva ecuación
	espera_nueva_ecuacion = true
	activa_ignorancia = false
	activa_numero = false
		
func mostrar_resumen():
	if is_inside_tree():
		# Cargar y crear la instancia de la pantalla de resumen
		var pantalla_resumen = load("res://Juego/pantalla_resumen.tscn").instantiate()
		if pantalla_resumen != null:
			pantalla_resumen.muestra_resumen(conocimiento, timer_juego)
			get_tree().root.add_child(pantalla_resumen)  # Añadir la escena de resumen al árbol de nodos.
			# Liberar la escena actual
			queue_free()
		else:
			print("Error: La escena 'pantalla_resumen.tscn' no se pudo cargar.")
	else:
		print("Error: El nodo principal no está disponible.")
