extends Node2D

func _ready() -> void:
	Dialogic.start("Final_Scene")
	Dialogic.signal_event.connect(_dialogic_signal)

func _dialogic_signal(arg):
	if arg == "end":
		await Game_Manager.change_scene_fade_out("res://scenes/UI/main_menu.tscn")
