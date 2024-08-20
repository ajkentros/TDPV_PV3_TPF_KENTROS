extends Control

func _ready():
	
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
