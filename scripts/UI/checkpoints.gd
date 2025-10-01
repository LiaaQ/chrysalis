extends Control

func _ready():
	for child in $VBoxLeft.get_children() + $VBoxRight.get_children():
		if child is Button:
			child.pressed.connect(_on_checkpoint_button_pressed.bind(child.name))

func _on_checkpoint_button_pressed(checkpoint_name: String) -> void:
	if not Game_Manager.checkpoints.has(checkpoint_name):
		print("No checkpoint found for:", checkpoint_name)
		return

	var scene_path = Game_Manager.checkpoints[checkpoint_name]
	if scene_path == "":
		print("Checkpoint", checkpoint_name, "has no scene assigned.")
		return

	var scene = load(scene_path)
	if scene:
		if Game_Manager.curr_song:
			Game_Manager.curr_song.stop()
		get_tree().change_scene_to_packed(scene)
	else:
		print("Failed to load scene at:", scene_path)

func _on_go_back_pressed() -> void:
	await Game_Manager.change_scene_fade_out("res://scenes/UI/main_menu.tscn")
