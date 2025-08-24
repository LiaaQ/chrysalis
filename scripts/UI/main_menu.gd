extends Control

var checkpoint = null

func _ready() -> void:
	Game_Manager.reset_variables()
	if not parse_file():
		$VBoxContainer/Button.queue_free()
	if Game_Manager.curr_song:
		Game_Manager.curr_song.stop()
	var song = Game_Manager.get_node("Level1/Sounds/Topdown_Depressing")
	song.play()
		
func parse_file():
	var save_path = "user://chrysalis_checkpoint.json"
	if FileAccess.file_exists("user://chrysalis_savegame.json"):
		var file = FileAccess.open("user://chrysalis_savegame.json", FileAccess.READ)
		var save_data = JSON.parse_string(file.get_as_text())
		file.close()
		if typeof(save_data) == TYPE_DICTIONARY and save_data.has("curr_checkpoint"):
			if Game_Manager.checkpoints.has(save_data["curr_checkpoint"]):
				checkpoint = save_data["curr_checkpoint"]
				return true

	return false

func _on_button_2_pressed() -> void:
	Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
	await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/Phase1/room.tscn")

func _on_button_3_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	if checkpoint:
		Game_Manager.load_checkpoint(checkpoint)

func _on_button_4_pressed() -> void:
	await Game_Manager.change_scene_fade_out("res://scenes/UI/checkpoints.tscn")
