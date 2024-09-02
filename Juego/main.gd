extends Node

@export var ignorancia_escena: PackedScene
@export var numero_escena: PackedScene

var conocimiento: int
var nivel: int  # Variable que indica el nivel actual
var timer_juego: float

var activa_ignorancia:bool = true	# Variable bool que activa la instancia de ignorancia
var activa_numero:bool = true		# Variable bool que activa la instancia de numero
var ecuacion_actual: String = ""	# Variable string para armar la ecuación
var operador_1: int					# Variable entera operador_1 de la ecuación
var operador_2: int					# Variable entera operador_2 de la ecuación
var resultado_esperado: int			# Variable entera resultado_esperado de la ecuación
var espera_nueva_ecuacion: bool = false		# Variable bool que avisa por una nueva ecuación
var ecuaciones_restantes: int = 5

var numeros_generados: int = 0	# Variable para contar los números que se generan
var numeros_restantes: int = 0  # Variable para contar los números en pantalla
var opciones = []

var area_min_x: int
var area_max_x: int
var area_min_y: int
var area_max_y: int
#var nivel_terminado:bool = false			# Variable bool que avisa si el juego terminó

func _ready():
	AudioManager.stop_musica_inicio()
	
	nivel = GameManager.nivel
	
	area_instancias()
	nuevo_game()

func nuevo_game():
	# Limpia pantalla de numeros e ignorancia
	get_tree().call_group("Ignorancia", "queue_free")
	get_tree().call_group("Numero", "queue_free")
	

	timer_juego = 0.0
	numeros_generados = 0
		
	$Astronauta.start()
	
	$TimerInicio.start()	
	
	conocimiento = GameManager.conocimiento
	$HUD.acualiza_conocimiento(conocimiento)
	$HUD.muestra_ecuacion("Estás listo?")
	
	AudioManager.play_musica_galaxia()
	
func sin_ecuaciones():
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
	$TimerEsperaEcuacion.stop()
	# Liberar la escena actual
	queue_free()
	GameManager.muestra_resumen(conocimiento, timer_juego)

	
func _process(delta):
	timer_juego += delta	
	
func _on_timer_inicio_timeout():
	#print("inicia el juego")
	generar_nueva_ecuacion()
	
func _on_timer_espera_ecuacion_timeout() -> void:
	if espera_nueva_ecuacion:
		espera_nueva_ecuacion = false
		generar_nueva_ecuacion()

func _on_timer_ignorancia_timeout() -> void:
	if activa_ignorancia:
		adiciona_ignorancia()
		
func _on_timer_numero_timeout():
	if activa_numero && numeros_generados < opciones.size():
		adicionar_numero(opciones[numeros_generados])
		numeros_generados += 1
	
func generar_nueva_ecuacion() -> void:
	operador_1 = randi_range(1, 10)
	operador_2 = randi_range(1, 10)
	
	if ecuaciones_restantes > 0:
		match nivel:
			1: # Suma
				genera_ecuacion_suma()	
			2: # Resta
				genera_ecuacion_resta()
			3: # Multiplicación
				genera_ecuacion_multiplicacion()
			4: # División
				genera_ecuacion_division()
		
		# Limpia la devolución anterior del HUD
		$HUD.muestra_ecuacion(ecuacion_actual)
		$HUD.muestra_devolucion("", Color.WHITE)
		
		generar_opciones(resultado_esperado)
		
		numeros_generados = 0
		numeros_restantes = opciones.size()  # Inicia el contador con el número de opciones generadas
		ecuaciones_restantes -= 1
		activa_ignorancia = true
		activa_numero = true
		$TimerNumero.start()
		$TimerIgnorancia.start()
		
	else:
		sin_ecuaciones()
		
func genera_ecuacion_suma():
	ecuacion_actual = str(operador_1) + " + " + str(operador_2) + " = ?"
	resultado_esperado = operador_1 + operador_2	
	
func genera_ecuacion_resta():
	resultado_esperado = operador_1 - operador_2
	ecuacion_actual = str(operador_1) + " - " + str(operador_2) + " = ?"

func genera_ecuacion_multiplicacion():
	resultado_esperado = operador_1 * operador_2
	ecuacion_actual = str(operador_1) + " * " + str(operador_2) + " = ?"

func genera_ecuacion_division():
	resultado_esperado = randi_range(1, 10)
	operador_1 = resultado_esperado * operador_2
	ecuacion_actual = str(operador_1) + " / " + str(operador_2) + " = ?"	

func generar_opciones(resultado_correcto: int) -> void:
	opciones.clear()  # Asegura que las opciones se reinicien cada vez
	#opciones = []
	opciones.append(resultado_correcto)
	
	for i in range(4):
		var opcion = resultado_correcto + (i - 2)  # Genera opciones cercanas al resultado
		if opcion not in opciones and opcion > 0:
			opciones.append(opcion)
	
	opciones.shuffle()

func adiciona_ignorancia():
	# Crea una instancia de ignorancia en la escena
	var ignorancia = ignorancia_escena.instantiate()
		
	# Genera una posición aleatoria dentro del área definida
	var posicion_ignorancia_x = randf_range(area_min_x, area_max_x)
	var posicion_ignorancia_y = randf_range(area_min_y, area_max_y)
	ignorancia.position = Vector2(posicion_ignorancia_x, posicion_ignorancia_y)
	
	# Define una dirección de movimiento aleatoria de ignorancia
	var direction = randf_range(-PI / 4, PI / 4)
	ignorancia.rotation = direction
		
	# Define la velocidad de ignorancia en forma aleaoria
	var min_velocidad = ignorancia.min_velocidad
	var max_velocidad = ignorancia.max_velocidad
	var velocity = Vector2(randf_range(min_velocidad, max_velocidad), 0.0)
	ignorancia.linear_velocity = velocity.rotated(direction)
	# Genera ignorancia en la escena Main
	add_child(ignorancia)
	
func adicionar_numero(valor: int) -> void:
	# Crea una instancia de un numero en la escena
	var numero = numero_escena.instantiate()
	
	# Conecta la señal numero_desaparecido a la función on_numero_desaparecido
	numero.connect("numero_fuera_pantalla",_on_numero_desaparecido)
	
	# Genera una posición aleatoria dentro del área definida
	var posicion_numero_x = randf_range(area_min_x, area_max_x)
	var posicion_numero_y = randf_range(area_min_y, area_max_y)
	numero.position = Vector2(posicion_numero_x, posicion_numero_y)
	
	# Define una dirección de movimiento aletoria de numero
	var direction = randf_range(-PI / 4.0 , PI / 4.0)
	numero.rotation = direction	

	# Define la velocidad de numero en forma aleaoria
	var max_velocidad = numero.max_velocidad
	var min_velocidad = numero.min_velocidad
	var velocity = Vector2(randf_range(min_velocidad, max_velocidad), 0.0).rotated(direction)
	numero.linear_velocity = velocity
		
	numero.muestra_numero(str(valor))
	# Genera numero en la escena Main
	add_child(numero)
	
func _on_numero_desaparecido() -> void:
	numeros_restantes -= 1
	# Si todos los números han salido de la pantalla y no ha habido colisión =>
	if numeros_restantes == 0 and !espera_nueva_ecuacion:
		despues_de_colision("no resolviste", Color.RED)	

		
func _on_astronauta_hit(numero: int) -> void:
	if numero == resultado_esperado:
		conocimiento += 1
		$HUD.acualiza_conocimiento(conocimiento)
		AudioManager.play_sonido_colision_numero_correcto()
		match nivel:
			1: # Suma
				ecuacion_actual = str(operador_1) + " + " + str(operador_2) + " = " + str(resultado_esperado)
			2: # Resta
				ecuacion_actual = str(operador_1) + " - " + str(operador_2) + " = " + str(resultado_esperado)
			3: # Multiplicación
				ecuacion_actual = str(operador_1) + " * " + str(operador_2) + " = " + str(resultado_esperado)
			4: # División
				ecuacion_actual = str(operador_1) + " / " + str(operador_2) + " = " + str(resultado_esperado)
		
		# Mostrar la ecuación completa en el HUD
		$HUD.muestra_ecuacion(ecuacion_actual)
				
		# Mostrar un mensaje de devolución
		despues_de_colision("bien resuelto", Color.GREEN)	
	else:
		AudioManager.play_sonido_colision_numero_incorrecto()
		despues_de_colision("no resolviste", Color.RED)

func _on_astronauta_colisiono_con_ignorancia() -> void:
	despues_de_colision("te atraparon", Color.RED)
	AudioManager.play_sonido_colision_ignorancia()
	GameManager.reduce_vida_estelar()
	$HUD.actualiza_vida_estelar()
	var vida_estelar = GameManager.vida_estelar
	if(vida_estelar <= 0):
		queue_free()
	
	
func despues_de_colision(mensaje, color: Color):
	# Limpiar todos los enemigos (ignorancia y números) en pantalla
	get_tree().call_group("Ignorancia", "queue_free")
	get_tree().call_group("Numero", "queue_free")
	
	# Mostrar un mensaje de devolución
	$HUD.muestra_devolucion(mensaje, color)
	
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
	activa_ignorancia = false
	activa_numero = false
	# Establecer una bandera o variable para indicar que se debe generar una nueva ecuación
	espera_nueva_ecuacion = true
	# Iniciar el TimerEsperaEcuacion para esperar 2 segundos
	$TimerEsperaEcuacion.start(2)


func verifica_juego():
	if espera_nueva_ecuacion:
		return  # Esperar a que el Timer termine antes de generar una nueva ecuación
	if ecuaciones_restantes == 0:
		sin_ecuaciones()
		
func detener_timers():
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
	$TimerEsperaEcuacion.stop()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ui_cancel es la acción por defecto para Escape en Godot
		$HUD.pause()
		
func area_instancias():
	# Obtiene el tamaño del viewport actual
	
	var screen_size = get_viewport().size
	# Define los límites del área basados en el tamaño del viewport
	area_min_x = 50
	area_max_x = screen_size.x - area_min_x
	area_min_y = 128
	area_max_y = screen_size.y - area_min_y
