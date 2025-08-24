extends Control

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	get_tree().paused = false
	queue_free()

func _on_button_3_pressed() -> void:
	save_checkpoint()
	get_tree().quit()

func save_checkpoint():
	var save_data = {
		"curr_checkpoint": Game_Manager.curr_checkpoint
	}
	var file = FileAccess.open("user://chrysalis_savegame.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()


func _on_button_4_pressed() -> void:
	get_tree().paused = false
	await Game_Manager.change_scene_fade_out("res://scenes/UI/main_menu.tscn")


func _on_button_2_pressed() -> void:
	$Control.visible = true
