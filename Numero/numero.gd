extends RigidBody2D

@warning_ignore("unused_signal")
signal numero_fuera_pantalla		# Referencia a la señal desapareció un número de pantalla
@export var min_velocidad = 50.0  	# Mínima velocidad del numero
@export var max_velocidad = 100.0  	# Máxima velocidad del número

func muestra_numero(text):
	$LabelNumero.text = text
	$LabelNumero.show()

func get_numero():
	# queue_free()
	return int($LabelNumero.text)
	
func get_tipo():
	return "numero"
	

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	emit_signal("numero_fuera_pantalla")  # Emite la señal antes de eliminar el nodo
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Astronauta"):
		get_parent().manejar_colision_numero(get_numero())
		queue_free()
