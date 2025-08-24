extends Node2D

@export var player: CharacterBody2D

func _ready() -> void:
	if Game_Manager.curr_song:
		Game_Manager.curr_song.stop()
	await get_tree().process_frame
	var spiders = get_node("Spiders")
	Game_Manager.max_spiders = spiders.get_children().size()
	Game_Manager.killed_spiders = 0
	if not player:
		player = Game_Manager.player
	Dialogic.start("arachno_start")

func return_back():
	Dialogic.start("arachno_finish")
	Game_Manager.curr_checkpoint = "Arachnophobia_After"
	Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
	await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/outside_after_arachno.tscn")
