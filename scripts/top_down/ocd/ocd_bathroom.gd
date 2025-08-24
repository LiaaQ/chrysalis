extends Node2D

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)
	
func _dialogic_signal(arg):
	if arg == "washed_hands":
		Game_Manager.washed_hands = true
