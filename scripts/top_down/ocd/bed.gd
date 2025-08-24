extends Interactable

@export var sprite_sleeping: Sprite2D

func _ready() -> void:
	super()
	
func interact():
	super()
	if Game_Manager.washed_hands and not Game_Manager.worried_about_door:
		sprite_sleeping.visible = true
		Game_Manager.player.visible = false
		Game_Manager.movement_locked = true
		Game_Manager.interaction_locked = true
		get_tree().create_timer(5.0).timeout
		Dialogic.start("bed_lock_door")
