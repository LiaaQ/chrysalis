extends Interactable

@export var interaction_to_disable: Interactable

func _ready() -> void:
	super()

func interact():
	rotation_degrees = 0
	Game_Manager.fixed_picture = true
	interaction_to_disable.queue_free()
	$Area2D.queue_free()
	$swoosh2.play()
