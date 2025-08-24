extends "res://scripts/top_down/fix_item.gd"

func _ready() -> void:
	super()
	manager_array = get_tree().current_scene.manager_array

func interact():
	super()
	if $Interactable11:
		Game_Manager.roll_acquired = true
		Dialogic.start("toilet_roll")
		$Interactable11.queue_free()
