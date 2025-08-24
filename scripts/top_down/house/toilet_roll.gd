extends "res://scripts/top_down/fix_item.gd"

func _ready() -> void:
	super()
	manager_array = get_tree().current_scene.manager_array

func interact():
	print(Game_Manager.roll_acquired)
	if Game_Manager.roll_acquired:
		super.interact()
	else: Dialogic.start("toilet_roll_before")
