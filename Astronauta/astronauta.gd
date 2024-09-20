extends Area2D


@warning_ignore("unused_signal")
signal hit		# Referencia a la señal denominada hit
@warning_ignore("unused_signal")
signal colisiono_con_ignorancia()

var speed = 400 	# Referencia a la velocidad del astronauta (pixels/sec).
var posicionInicialAstronauta: Vector2

var screen_size		# Referencia al tamaño de la ventana del juego
var sprite_size  	# Referencia al tamaño del sprite del astonauta

var area_min_x: int
var area_max_x: int
var area_min_y: int
var area_max_y: int

var se_mueve_abajo = false		# Referencia del movimiento del astronauta hacia abajo
var mouse_posicion: Vector2 = Vector2.ZERO
var movimiento_mouse = false  	# Variable para controlar el modo de movimiento
var error_movimiento = 10.0  	# distancia mínima de movimiento para evitar vibraciones
var permitir_movimiento_mouse = false  # Bandera para permitir el movimiento del mouse

var mouse_suavizado = 0.1  # Valor de suavizado, ajusta según lo necesites

var nivel: int  # Variable para el nivel actual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nivel = GameManager.nivel
	#
	area_posicion_inicial()
	
	# Esconde el canvas
	hide()		
	# Posiciona al astronauta en una posición inical
	start()
	
	#cambiar_color_segun_nivel(nivel)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Referencia a la velocidad del astronauta como un vetor
	var velocity = Vector2.ZERO 		
	
	# Movimiento con teclas
	# Si se hace clic a la derecha => incrementa la velocidad en el eje x en 1
	if Input.is_action_pressed("mover_derecha"):
		velocity.x += 1	
		movimiento_mouse = false
	# Si se hace clic a la izquierda  => incrementa la velocidad en el eje x en -1
	if Input.is_action_pressed("mover_izquierda"):
		velocity.x -= 1
		movimiento_mouse = false
	# Si se hace clic a la abajo => incrementa la velocidad en el eje y en 1
	if Input.is_action_pressed("mover_abajo"):
		velocity.y += 1
		movimiento_mouse = false
	# Si se hace clic a arriba => incrementa la velocidad en el eje y en -1
	if Input.is_action_pressed("mover_arriba"):
		velocity.y -= 1
		movimiento_mouse = false
		
	if velocity == Vector2.ZERO and permitir_movimiento_mouse and movimiento_mouse:
		var direccion = (mouse_posicion - global_position).normalized()
		var distancia_al_mouse = global_position.distance_to(mouse_posicion)
	
		if distancia_al_mouse > error_movimiento:
			velocity = velocity.lerp(direccion * speed, mouse_suavizado) * min(distancia_al_mouse / 100, 1)
		else:
			movimiento_mouse = false  # Deja de moverse si está cerca del objetivo
			
	
	# Aplica el movimiento si hay velocidad
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		actualizar_animacion(velocity)
	else:
		detener_animacion()
	
	# Actualiza la posición
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func actualizar_animacion(velocity: Vector2) -> void:
	# Movimiento horizontal
	if abs(velocity.x) > abs(velocity.y):
		$astronauta.show()
		match nivel:
			1:
				$astronauta/AnimationAstronauta.play("astronauta_camina")
			2: 
				$astronauta/AnimationAstronauta.play("astronauta_camina_2")
			3:
				$astronauta/AnimationAstronauta.play("astronauta_camina_3")
			4:
				$astronauta/AnimationAstronauta.play("astronauta_camina_4")
		
		$astronauta.flip_v = false  # Asegura que no esté volteado verticalmente
		$astronauta.flip_h = velocity.x < 0  # Cambia flip_h del nodo correcto
	# Movimiento vertical
	elif abs(velocity.y) >= abs(velocity.x):
		$astronauta.show()
		match nivel:
			1:
				$astronauta/AnimationAstronauta.play("astronauta_arriba")
			2: 
				$astronauta/AnimationAstronauta.play("astronauta_arriba_2")
			3:
				$astronauta/AnimationAstronauta.play("astronauta_arriba_3")
			4:
				$astronauta/AnimationAstronauta.play("astronauta_arriba_4")
		
		
		se_mueve_abajo = velocity.y > 0
		$astronauta.flip_v = velocity.y > 0  # Cambiar flip_v del nodo correcto
		
	
	else:
		detener_animacion()

func detener_animacion() -> void:
	# Detener todas las animaciones y mostrar el estado de reposo
	$astronauta.show()
	match nivel:
			1:
				$astronauta/AnimationAstronauta.play("astronauta_reposa")
			2: 
				$astronauta/AnimationAstronauta.play("astronauta_reposa_2")
			3:
				$astronauta/AnimationAstronauta.play("astronauta_reposa_3")
			4:
				$astronauta/AnimationAstronauta.play("astronauta_reposa_4")
	
	$astronauta.flip_v = false  # Restablece el flip vertical para que no quede al revés
	


func _input(event):
	# Activa movimiento si el mouse se mueve
	if event is InputEventMouseMotion:
		# Activar el movimiento del mouse solo cuando el mouse se mueve por primera vez
		if not permitir_movimiento_mouse:
			permitir_movimiento_mouse = true
		mouse_posicion = get_global_mouse_position()	
		movimiento_mouse = true
		
	
# Gestiona la colisión del astronauta con ignorancia
func _on_body_entered(body):
	if body.is_in_group("Numero"):
		emit_signal("hit", body.get_numero())
		body.queue_free()
	elif body.is_in_group("Ignorancia"):
		emit_signal("colisiono_con_ignorancia")
		body.queue_free()
	else:
		# Astronauta desaparece despúes de ser golpeado
		hide()
		# Si colisiona se desactiva el colisionador (CollisionShape2D) del astronauta para evitar múltiples señales hit
		$CollisionShape2D.set_deferred("disabled", true)
	
# gestiona la aparición del astronauta cada vez que comienza el juego	
func start():
	# Actualiza la posición inicial con la posición actual del mouse
	posicionInicialAstronauta = get_global_mouse_position()
	
	# Posiciona al astronauta en la posición del mouse
	position = posicionInicialAstronauta
	
	## Genera una posición aleatoria dentro del área definida
	#var posicionInicialAstronauta_x = randf_range(area_min_x, area_max_x)
	#var posicionInicialAstronauta_y = randf_range(area_min_y, area_max_y)
	#posicionInicialAstronauta = Vector2(posicionInicialAstronauta_x, posicionInicialAstronauta_y)
	position = posicionInicialAstronauta
	
	show()
	
	$CollisionShape2D.disabled = false

func area_posicion_inicial():
	# Define al tamaño de la pantalla de juego = límites definidos en el viewprot
	screen_size = get_viewport_rect().size
	# Define los límites del área basados en el tamaño del viewport
	area_min_x = 100
	area_max_x = screen_size.x
	area_min_y = 200
	area_max_y = screen_size.y - area_min_y
	
	
