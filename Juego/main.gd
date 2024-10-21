extends Node

@export var ignorancia_escena: PackedScene
@export var numero_escena: PackedScene

@export var hud_suma_escena: PackedScene
@export var hud_resta_escena: PackedScene
@export var hud_multiplicacion_escena: PackedScene
@export var hud_division_escena: PackedScene

@export var fondo_suma: Texture2D
@export var fondo_resta: Texture2D
@export var fondo_multiplicacion: Texture2D
@export var fondo_division: Texture2D

var hud_actual  # Almacena la referencia del HUD instanciado
var sprite_fondo: Sprite2D

var conocimiento: int
var nivel: int  # Variable que indica el nivel actual
var timer_juego: float

var activa_ignorancia:bool = true	# Variable bool que activa la instancia de ignorancia
var activa_numero:bool = true		# Variable bool que activa la instancia de numero
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
	# Accede al Sprite2D que está en la jerarquía de Main
	sprite_fondo = $Sprite2D
	# Detiene la música de inicio
	AudioManager.stop_musica_inicio()
	# Inicializa el nivel desde el GameManager 
	nivel = GameManager.nivel
	# Carga y añade la escena de HUD correspondiente al nivel
	carga_hud_para_nivel()
	# Define el área de las instancias
	area_instancias()
	# Comienza un nuevo juego
	nuevo_game()

func carga_hud_para_nivel():
	var hud_escena
	match nivel:
		1:
			hud_escena = hud_suma_escena.instantiate()
			sprite_fondo.texture = fondo_suma
		2:
			hud_escena = hud_resta_escena.instantiate()
			sprite_fondo.texture = fondo_resta
		3:
			hud_escena = hud_multiplicacion_escena.instantiate()
			sprite_fondo.texture = fondo_multiplicacion
		4:
			hud_escena = hud_division_escena.instantiate()
			sprite_fondo.texture = fondo_division
	
	# Añade HUD correspondiente a la escena
	add_child(hud_escena)  
	# Guarda la referencia del HUD instanciado
	hud_actual = hud_escena
	# Llama a la función para inicializar el HUD según el nivel
	hud_actual.inicializa_hud(nivel)
	# Conectar la señal opciones_generadas del HUD y llanar a la función _on_opciones_generadas
	hud_actual.connect("opciones_generadas", Callable(self, "_on_opciones_generadas"))  
	
func nuevo_game():
	# Limpia pantalla de numeros e ignorancia
	get_tree().call_group("Ignorancia", "queue_free")
	get_tree().call_group("Numero", "queue_free")
	

	timer_juego = 0.0
	numeros_generados = 0
	
	# Comprobación de visibilidad al iniciar el juego
	#print("Astronauta visible:", $Astronauta.visible)
		
	$Astronauta.start()
	$TimerIgnorancia.start()
	$TimerInicio.start()	
	#
	conocimiento = GameManager.conocimiento
	#
	hud_actual.acualiza_conocimiento(conocimiento)
	hud_actual.muestra_ecuacion("Estás listo?")
	
	AudioManager.play_musica_galaxia()
	
# 
func _on_opciones_generadas(opciones_generadas: Array):
	opciones = opciones_generadas
# Reinicia el contador de números generados
	numeros_generados = 0
	numeros_restantes = opciones.size()
# Reinicia el timer para generar los números
	$TimerNumero.start()  
# 	
func _on_timer_inicio_timeout():
# Llama a la función en el HUD para generar una nueva ecuación
	hud_actual.generar_nueva_ecuacion()
# Inicia la generación de ignorancia después de mostrar la primera ecuación
	$TimerIgnorancia.start()
	
#	
func _on_timer_numero_timeout():
	if activa_numero && numeros_generados < opciones.size():
		adicionar_numero(opciones[numeros_generados])
		numeros_generados += 1

# 		
func adicionar_numero(valor: int) -> void:
# Crea una instancia de un numero en la escena
	var numero = numero_escena.instantiate()
# Conecta la señal numero_desaparecido a la función on_numero_desaparecido
	numero.connect("numero_fuera_pantalla",Callable(self, "_on_numero_desaparecido"))
# Genera una posición aleatoria dentro del área definida
	var posicion_numero_x = randf_range(area_min_x, area_max_x)
	var posicion_numero_y = randf_range(area_min_y, area_max_y)
	numero.position = Vector2(posicion_numero_x, posicion_numero_y)
	#print("Número generado en posición:", numero.position)
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
	#numeros_restantes += 1

#	
func _on_numero_desaparecido() -> void:
	numeros_restantes -= 1
	# Si todos los números han salido de la pantalla y no ha habido colisión =>
	if numeros_restantes == 0 and !espera_nueva_ecuacion:
		despues_de_colision("no resolviste", Color.RED)	
		
#		
func _on_astronauta_hit(numero: int) -> void:
# Si el número interceptado = resltado esperado => 
	if hud_actual.validar_respuesta(numero):
# Incrementa conocimiento		
		conocimiento += 1
# Actualiza HUD
		hud_actual.acualiza_conocimiento(conocimiento)
# Dispara sonido de colisión correcta
		AudioManager.play_sonido_colision_numero_correcto()
# Muestra la ecuación resuelta en el HUD
		hud_actual.muestra_ecuacion_resuelta()
# Muestra un mensaje de devolución
		despues_de_colision("bien resuelto", Color.GREEN)	
	else:
# Dispara sonido de colisión incorrecta
		AudioManager.play_sonido_colision_numero_incorrecto()
# 
		despues_de_colision("no resolviste", Color.RED)		
		
#	
func despues_de_colision(mensaje, color: Color):
# Limpia todos los enemigos (ignorancia y números) en pantalla
	get_tree().call_group("Ignorancia", "queue_free")
	get_tree().call_group("Numero", "queue_free")
# Muestra un mensaje de devolución
	hud_actual.muestra_devolucion(mensaje, color)
 # Detiene los timers de números e ignoranci# 
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
# Si ecuaciones_restantes > 0 => 
	if ecuaciones_restantes > 0:
		ecuaciones_restantes -= 1
# Verifica si el juego debe continuar o si ha terminado	
	verifica_juego()
# Establece una bandera para indicar que se debe generar una nueva ecuación
	espera_nueva_ecuacion = true
# Inicia el TimerEsperaEcuacion para esperar 2 segundos
	$TimerEsperaEcuacion.start(2)
		
# Gestiona el timeout del timer para esperar la nueva ecuación	
func _on_timer_espera_ecuacion_timeout() -> void:
# Si espera_nueva_ecuacion = true => false
	if espera_nueva_ecuacion:
		espera_nueva_ecuacion = false
# Generar nueva ecuación desde el HUD
		hud_actual.generar_nueva_ecuacion()
# Reinicia el contador de números generados
		numeros_generados = 0
		numeros_restantes = 0
# Actualizar las opciones
		opciones = hud_actual.obtener_opciones()
# Reactiva las variables de generación
		activa_ignorancia = true
		activa_numero = true
# Reinicia los timers de números e ignorancia
		$TimerNumero.start()
		$TimerIgnorancia.start()

# Gestiona el timeout del timer de ignorancia
func _on_timer_ignorancia_timeout() -> void:
# Si activa_ignorancia = true => llama a la función
	if activa_ignorancia:
		
		adiciona_ignorancia()
		
# Instancia  ignorancia en la escena en posiciones aleatorias
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

# Gestiona la colisión del astronauta con ignorancia
func _on_astronauta_colisiono_con_ignorancia() -> void:
# Muestra mensaje de colisión con color rojo
	despues_de_colision("te atraparon", Color.RED)
# Reproduce sonido de colisión con ignorancia
	AudioManager.play_sonido_colision_ignorancia()
# Reduce la vida estelar en el GameManager
	GameManager.reduce_vida_estelar()
# Actualiza la visualización de las vidas en el HUD
	hud_actual.actualiza_vida_estelar()
# Verifica si la vida estelar llegó a cero
	var vida_estelar = GameManager.vida_estelar
# Si no quedan vidas => libera el nodo actual (terminar el juego)
	if(vida_estelar <= 0):
		queue_free()
	
# Gestiona si quedan ecuaciones o si ya se resolvieron todas
func verifica_juego():
# Si espera_nueva_ecuacion = true => no hacer nada
	if espera_nueva_ecuacion:
		return  
# Si ecuaciones_restantes = 0 => llama a la función 		
	if ecuaciones_restantes == 0:
		sin_ecuaciones()

# Gestiona la detención de los timers		
func detener_timers():
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
	$TimerEsperaEcuacion.stop()
	
# Gestiona del input para pausar el juego al presionar Escape
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ui_cancel es la acción por defecto para Escape en Godot
		hud_actual.pause()

# Gestiona cuando ya no quedan ecuaciones por resolver
func sin_ecuaciones():
	$TimerNumero.stop()
	$TimerIgnorancia.stop()
	$TimerEsperaEcuacion.stop()
# Liberar la escena actual
	queue_free()
	GameManager.muestra_resumen(conocimiento, timer_juego)

# Gestiona el área de generación de instancias basado en el tamaño del viewpor 
func area_instancias():
# Obtiene el tamaño del viewport actual
	var screen_size = get_viewport().size
# Define los límites del área basados en el tamaño del viewport
	area_min_x = 50
	area_max_x = screen_size.x - area_min_x - 100
	area_min_y = 128
	area_max_y = screen_size.y - area_min_y - 100

#	
func _process(delta):
	timer_juego += delta	
