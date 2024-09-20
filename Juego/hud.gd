extends CanvasLayer

@export var boton_pausa : Texture
@export var boton_play : Texture

@onready var button_pausa = $ButtonPausa

var tipo_operacion: int  # Almacena el tipo de operación según el nivel
var operador_1: int
var operador_2: int
var resultado_esperado: int		# Almacena el resultado esperado
var ecuacion_actual: String  	# Almacena la ecuación actual
var ecuacion_resuelta: String  	# Almacena la ecuación resuelta
var opciones = []

@warning_ignore("unused_signal")
signal opciones_generadas(opciones: Array)

# Inicializa el HUD según el nivel
func inicializa_hud(nivel: int):
	tipo_operacion = nivel
	actualiza_vida_estelar()
	acualiza_conocimiento(GameManager.conocimiento)
	generar_nueva_ecuacion()
	
# Actualiza las vidas que tiene el astronauta
func actualiza_vida_estelar():
	var vidas = GameManager.vida_estelar		
	var vida_container = $HBoxContainer
# Itera sobre los sprites en el HBoxContainer
	for i in range(vida_container.get_child_count()):
		var sprite = vida_container.get_child(i)
		# Activa o desactiva la visibilidad según el número de vidas restantes
		if i < vidas:
			sprite.visible = true
		else:
			sprite.visible = false	
	
# Muestra la ecuación actual en el HUD			
func acualiza_conocimiento(conocimiento):
	$LabelConocimiento.text = str(conocimiento)
		
# Genera una nueva ecuación según el tipo de operación (suma, resta, multiplicación, división)
func generar_nueva_ecuacion():
	operador_1 = randi_range(1, 10)
	operador_2 = randi_range(1, 10)
	
	
	match tipo_operacion:
		1:
			generar_ecuacion_suma()
		2:
			generar_ecuacion_resta()
		3:
			generar_ecuacion_multiplicacion()
		4:
			generar_ecuacion_division()
# Emite la señal con las nuevas opciones
	generar_opciones(resultado_esperado)
# Muestra la ecuación en el HUD		
	muestra_ecuacion(armar_ecuacion())

func generar_opciones(resultado: int) -> Array:
	opciones = []
	# Agregar el resultado correcto
	opciones.append(resultado)
	# Añadir dos opciones por encima y dos por debajo, sin repetición
	var rango_inferior = resultado - 2
	var rango_superior = resultado + 2

# Creaa un conjunto de posibles opciones (2 abajo y 2 arriba)
	for i in range(rango_inferior, rango_superior + 1):
		if i != resultado:  # Evitar el resultado correcto
			opciones.append(i) 
# Asegurar que no hay repeticiones (si hubiera alguna lógica previa con repeticiones)
	opciones.shuffle()  # Mezclar las opciones
	emit_signal("opciones_generadas", opciones)  # Emitir las opciones generadas
	return opciones
	
# Obtiene las opciones generadas
func obtener_opciones() -> Array:
	return opciones
	
func generar_ecuacion_suma():
	ecuacion_actual = str(operador_1) + " + " + str(operador_2) + " = ?"
	resultado_esperado = operador_1 + operador_2
	ecuacion_resuelta = str(operador_1) + " + " + str(operador_2) + " = " + str(resultado_esperado)

func generar_ecuacion_resta():
	ecuacion_actual = str(operador_1) + " - " + str(operador_2) + " = ?"
	resultado_esperado = operador_1 - operador_2
	ecuacion_resuelta = str(operador_1) + " + " + str(operador_2) + " = " + str(resultado_esperado)

func generar_ecuacion_multiplicacion():
	ecuacion_actual = str(operador_1) + " * " + str(operador_2) + " = ?"
	resultado_esperado = operador_1 * operador_2
	ecuacion_resuelta = str(operador_1) + " + " + str(operador_2) + " = " + str(resultado_esperado)

func generar_ecuacion_division():
	operador_2 = randi_range(1, 10)
	resultado_esperado = randi_range(1, 10)
	operador_1 = resultado_esperado * operador_2
	ecuacion_actual = str(operador_1) + " / " + str(operador_2) + " = ?"
	ecuacion_resuelta = str(operador_1) + " + " + str(operador_2) + " = " + str(resultado_esperado)

func armar_ecuacion() -> String:
	return ecuacion_actual	
		
# Muestra la ecuación actual en el HUD
func muestra_ecuacion(ecuacion: String):
	$LabelEcuacion.text = ecuacion
	$LabelEcuacion.show()
	
func muestra_ecuacion_resuelta():
	$LabelEcuacion.text = ecuacion_resuelta
	$LabelEcuacion.show()

# Valida si el número seleccionado es correcto
func validar_respuesta(numero: int) -> bool:
	return numero == resultado_esperado	

# Muestra mensajes temporales en el HUD	
func muestra_devolucion(mensaje: String, color: Color):
	$LabelDevolucion.text = mensaje
	$LabelDevolucion.modulate = color  # Hacer el texto completamente transparente
	$LabelDevolucion.show()
	$TimerMensaje.start()
	
# Oculta los mensajes temporales
func _on_timer_mensaje_timeout():
	$LabelEcuacion.hide()
	$LabelDevolucion.hide()

# Maneja el botón de pausa
func _on_button_pausa_pressed() -> void:
	pause()

# Pausa y reanuda el juego
func pause():
	if Engine.time_scale == 1.0:
		button_pausa.icon = boton_play
		muestra_devolucion("Pausado", Color.YELLOW) 
		Engine.time_scale = 0.0  # Pausa el juego
		 
	else:
		Engine.time_scale = 1.0  # Reanuda el juego
		button_pausa.icon = boton_pausa
		muestra_devolucion("", Color.WHITE)  # Opcional: oculta el mensaje de pausa
		
