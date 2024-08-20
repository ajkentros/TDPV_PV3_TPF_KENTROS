extends Control

@export var suma : Texture
@export var resta : Texture
@export var multiplicacion : Texture
@export var division : Texture

func _ready():
	if GameManager.game_over == false:
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
		#$LabelNivel.text = str(GameManager.nivel_texto)
		#$LabelNivel.show()
	else:
		$SiguienteNivel.visible = false
		$TextoNivel.text = "El Juego Finalizó"

	muestra_conocimiento_tiempo()
		
func muestra_conocimiento_tiempo():
	$LabelConocimiento.text = str(GameManager.conocimiento)
	$LabelConocimiento.show()
	
	var tiempo_jugado_int = int(GameManager.tiempo_juego)
	@warning_ignore("integer_division")
	var minutos = (tiempo_jugado_int / 60)
	var segundos = (tiempo_jugado_int % 60)
	var tiempo_formateado = str(minutos) + ":" + str(segundos) + " min"
	
	$LabelTiempo.text = tiempo_formateado
	$LabelConocimiento.show()

func _on_volver_pressed() -> void:

	var pantalla_inicio = load("res://Juego/pantalla_inicio.tscn").instantiate()	
	get_tree().root.add_child(pantalla_inicio)
	queue_free()

func _on_siguiente_nivel_pressed() -> void:
	
	GameManager.resetea_vida_estelar()
	GameManager.nivel += 1		# Incrementa nivel
	var main_scene = load("res://Juego/Main.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	queue_free()
