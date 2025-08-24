extends Node2D

func _ready() -> void:
	if Game_Manager.curr_song:
		Game_Manager.curr_song.stop()
	Dialogic.signal_event.connect(_dialogic_signal)
	Dialogic.start("nycto_start")

func _on_lamp_8_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		Dialogic.start("nycto_finish")

func _dialogic_signal(arg):
	if arg == "leave":
		Game_Manager.curr_checkpoint = "Nyctophobia_After"
		Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
		await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/nycto/Nycto_bedroom_after.tscn")
