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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var nivel = GameManager.nivel
	#
	area_posicion_inicial()
	
	# Obtiene el tamaño del sprite de la primera animación
	var sprite_frames = $AnimatedSprite2D.get_sprite_frames()
	var frame_texture = sprite_frames.get_frame_texture("astronauta_camina", 0)
	sprite_size = frame_texture.get_size() * 0.5
	
	# Esconde el canvas
	hide()		
	# Posiciona al astronauta en una posición inical
	start()
	
	cambiar_color_segun_nivel(nivel)
	
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
		
	# Movimiento con el mouse solo si se ha permitido
	if permitir_movimiento_mouse and movimiento_mouse:
		var direccion = (mouse_posicion - global_position).normalized()
		var distance_al_mouse = global_position.distance_to(mouse_posicion)
		# Aplica movimiento solo si la distancia al mouse es mayor que el umbral de error_movimiento
		if distance_al_mouse > error_movimiento:
			velocity = direccion * speed * min(distance_al_mouse / 100, 1)
		else:
			velocity = Vector2.ZERO
			movimiento_mouse = false
		
	# Aplica el movimiento solo si se ha detectado movimiento
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		if not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play()
	else:
		if $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.stop()
		
	# El vector position se incrementa con la velocidad por el tiempo delta	
	position += velocity * delta
	# El vector position = componente entre el vector zero y el tamaño de la pantalla (para no abandonar la pantalla)	
	position = position.clamp(Vector2.ZERO, screen_size)
	# Si la velocidad en x dstinta 0 =>
	# 	la animation se establece en astronauta_camina
	#	la inversión vertical de animación = false
	#	la inversión horizontal de animación = si velocidad en x < 0
	# Sino =>
	#	la animation se establece en astronauta_arriba
	#	la inversión vertical de animación = true
	#	la inversión horizontal de animación = si velocidad en y > 0
	if velocity.x != 0:
		$AnimatedSprite2D.animation = "astronauta_camina"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "astronauta_arriba"
		se_mueve_abajo = velocity.y < 0
		$AnimatedSprite2D.flip_v = velocity.y > 0
	else:
		# Si la velocidad es cero, significa que el personaje se detuvo =>
			# Vuelve a la posición original
		if se_mueve_abajo && velocity.length() == 0:
			$AnimatedSprite2D.flip_v = false  
			$AnimatedSprite2D.flip_h = false 
			$AnimatedSprite2D.animation = "astronauta_reposo"
			se_mueve_abajo = false
		
	# Ajustar la posición del astronauta
	var new_position = position + velocity * delta
	new_position.x = clamp(new_position.x, sprite_size.x / 2, screen_size.x - sprite_size.x / 2)
	new_position.y = clamp(new_position.y, sprite_size.y / 2, screen_size.y - sprite_size.y / 2)
	position = new_position
	

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
	
func cambiar_color_segun_nivel(nivel: int) -> void:
	# Carga el shader
	var shader = preload("res://Astronauta/Texturas/contorno_astronauta.gdshader")
	# Crea un ShaderMaterial y asignar el shader cargado
	var shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	# Asigna el ShaderMaterial al AnimatedSprite2D
	$AnimatedSprite2D.material = shader_material
	# Cambia el color del contorno según el nivel
	match nivel:
		1:
			shader_material.set_shader_parameter("new_color",Color(0.0, 0.0, 0.0, 1.0))
			#shader_material.set_shader_parameter("new_color",Color(1.0, 0.0, 0.0, 1.0))
					
			#shader_material.set("new_color", Color(0.757, 0.925, 0.835, 1.0))  # Blanco, color por defecto
		2:
			shader_material.set_shader_parameter("new_color", Color(1.0, 0.0, 0.0, 1.0))  # Rosa claro
		3:
			shader_material.set_shader_parameter("new_color", Color(0.5, 0.5, 1.0, 1.0))  # Azul claro
		4:
			shader_material.set_shader_parameter("new_color", Color(0.5, 1, 0.5, 1.0))  # Verde claro
		
