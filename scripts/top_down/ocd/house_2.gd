extends Node2D

@export var picture_to_crook: Interactable
@export var door_outside: Interactable
@export var bookshelf_dialogue_col: CollisionShape2D
@export var companion: Interactable

func _ready() -> void:
	var song = Game_Manager.get_node("Level3/Lofi")
	if not song.playing:
		song.play()
		Game_Manager.curr_song = song
	companion.sprite.modulate.a = 0
	Dialogic.signal_event.connect(_dialogic_signal)
	if Game_Manager.worried_about_door:
		door_outside.dialogic_timeline = "locking_door"
	if not Game_Manager.ocd_entered_house:
		Dialogic.start("enter_house_ocd")
		Game_Manager.ocd_entered_house = true
	else: $Interactions/CrookPicture.queue_free()
	

func _on_crook_picture_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		if picture_to_crook.rotation_degrees != -4.5:
			picture_to_crook.rotation_degrees = -4.5
			picture_to_crook.get_node("Area2D").get_node("CollisionShape2D").set_deferred("disabled", false)
			picture_to_crook.get_node("swoosh").play()
			Dialogic.start("crooked_picture")
		else:
			Dialogic.start("crooked_picture_2")

func _dialogic_signal(arg):
	if arg == "companion_fadein":
		companion.fade_in()
	if arg == "locked_door":
		bookshelf_dialogue_col.set_deferred("disabled", false)
	if arg == "OCD_platformer_start":
		Game_Manager.curr_checkpoint = "OCD_Bossfight"
		await Game_Manager.change_scene_fade_out("res://scenes/Platformer/OCD/platformer_ocd_bossfight.tscn")
