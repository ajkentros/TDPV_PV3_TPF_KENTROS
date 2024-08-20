extends CanvasLayer

@export var boton_pausa : Texture
@export var boton_play : Texture

@onready var button_pausa = $ButtonPausa

@export var suma : Texture
@export var resta : Texture
@export var multiplicacion : Texture
@export var division : Texture


func _ready() -> void:
	var nivel = GameManager.nivel
	match nivel:
		1: # Suma
			$SpriteNivel.set_texture(suma)
		2: # Resta
			$SpriteNivel.set_texture(resta)
		3: # Multiplicación
			$SpriteNivel.set_texture(multiplicacion)
		4: # División
			$SpriteNivel.set_texture(division)
func acualiza_conocimiento(conocimiento):
	$LabelConocimiento.text = str(conocimiento)
	
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
	

	
# Muestra el mensaje 
func muestra_ecuacion(text):
	$LabelEcuacion.text = text
	$LabelEcuacion.show()

func muestra_devolucion(mensaje: String, color: Color):
	$LabelDevolucion.text = mensaje
	$LabelDevolucion.modulate = color  # Hacer el texto completamente transparente
	$LabelDevolucion.show()
	
func _on_timer_mensaje_timeout():
	$LabelEcuacion.hide()
	$LabelDevolucion.hide()

func _on_button_pausa_pressed() -> void:
	pause()

func pause():
	if Engine.time_scale == 1.0:
		button_pausa.icon = boton_play
		muestra_devolucion("Pausado", Color.YELLOW) 
		Engine.time_scale = 0.0  # Pausa el juego
		 
	else:
		Engine.time_scale = 1.0  # Reanuda el juego
		button_pausa.icon = boton_pausa
		muestra_devolucion("", Color.WHITE)  # Opcional: oculta el mensaje de pausa
