extends Node2D

@export var picture_to_crook: Interactable
@export var companion: Interactable

func _ready() -> void:
	var song = Game_Manager.get_node("Level3/Lofi")
	if not song.playing:
		Game_Manager.curr_song = song
		song.play()
	if companion:
		companion.sprite.modulate.a = 0
	Dialogic.signal_event.connect(_dialogic_signal)

func _on_crook_picture_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		if picture_to_crook.rotation_degrees != -4.5:
			picture_to_crook.rotation_degrees = -4.5
			picture_to_crook.get_node("swoosh").play()
			Dialogic.start("crooked_picture_after")

func _dialogic_signal(arg):
	pass
