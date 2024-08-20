extends Node2D


func _on_volver_pressed() -> void:
	var pantalla_inicio = load("res://Juego/pantalla_inicio.tscn").instantiate()	
	get_tree().root.add_child(pantalla_inicio)
	queue_free()
