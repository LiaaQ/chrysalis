extends Interactable

@export var sprite_sleeping: Sprite2D

func _ready() -> void:
	super()
	
func interact():
	super()
	sprite_sleeping.visible = true
	Game_Manager.player.visible = false
	Game_Manager.movement_locked = true
	Game_Manager.interaction_locked = true
