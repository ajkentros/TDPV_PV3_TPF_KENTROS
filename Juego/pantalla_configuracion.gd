extends Control

var controles_sonidos_mostrados := false
var controles_musica_mostrados := false

func _ready() -> void:
	$Sonidos/HSliderSonidos.hide()
	$Sonidos/SonidosMute.hide()
	$Musica/HSliderMusica.hide()
	$Musica/MusicaMute.hide()
	
func _on_sonidos_pressed() -> void:
	controles_sonidos_mostrados =  !controles_sonidos_mostrados
	$Sonidos/HSliderSonidos.visible = controles_sonidos_mostrados
	$Sonidos/SonidosMute.visible = controles_sonidos_mostrados
	
func _on_sonidos_mute_pressed() -> void:
	AudioManager.toggle_mute_sonido()

func _on_h_slider_sonidos_value_changed(value: float) -> void:
	AudioManager.set_volumen_sonido(value)
	
func _on_musica_pressed() -> void:
	controles_musica_mostrados =  !controles_musica_mostrados
	$Musica/HSliderMusica.visible = controles_musica_mostrados
	$Musica/MusicaMute.visible = controles_musica_mostrados
	
func _on_musica_mute_pressed() -> void:
	AudioManager.toggle_mute_musica()

func _on_h_slider_musica_value_changed(value: float) -> void:
	AudioManager.set_volumen_musica(value)
	
func _on_volver_pressed() -> void:
	
	var pantalla_inicio = load("res://Juego/pantalla_inicio.tscn").instantiate()	
	get_tree().root.add_child(pantalla_inicio)
	queue_free()
