extends Control

func _on_iniciar_galaxia_pressed() -> void:
	GameManager.resetea_inicio()
	var pantalla_main = load("res://Juego/Main.tscn").instantiate()	
	get_tree().root.add_child(pantalla_main)
	queue_free()
	
func _on_configuracion_pressed() -> void:
	var pantalla_configuracion = load("res://Juego/pantalla_configuracion.tscn").instantiate()	
	get_tree().root.add_child(pantalla_configuracion)
	queue_free()
	
func _on_ayuda_pressed() -> void:
	var pantalla_ayuda = load("res://Juego/pantalla_ayuda.tscn").instantiate()	
	get_tree().root.add_child(pantalla_ayuda)
	queue_free()

func _on_creditos_pressed() -> void:
	var pantalla_creditos = load("res://Juego/pantalla_creditos.tscn").instantiate()	
	get_tree().root.add_child(pantalla_creditos)
	queue_free()
		
func _on_salir_pressed() -> void:
	get_tree().quit()
