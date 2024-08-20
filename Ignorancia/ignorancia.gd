extends RigidBody2D

@export var min_velocidad = 150  # Mínima velocidad de ignorancia.
@export var max_velocidad = 250  # Máxima velocidad de ignorancia.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var ignorancia_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(ignorancia_types[randi() % ignorancia_types.size()])
	
func get_tipo():
	return "ignorancia"
	
func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
