extends Node2D

@export var camera: Camera2D
@export var npc: CharacterBody2D
@export var companion: Interactable

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)
	Dialogic.start("social_finish_conversation")
	companion.fade_out()

func _process(delta: float) -> void:
	pass

func _dialogic_signal(arg):
	if arg == "switch_to_ocd":
		call_deferred("_switch_character")

func _switch_character():
	Game_Manager.movement_locked = true
	Game_Manager.player.set_script(load("res://scripts/top_down/lockscene/patrick_switch.gd"))
	Game_Manager.player._new_ready()
	
	var new_player = preload("res://scenes/Top_Down/player_top_down_3.tscn").instantiate()
	new_player.global_position = npc.global_position
	get_tree().current_scene.get_node("YSort").add_child(new_player)
	new_player.sprite.play("idle_front")
	Game_Manager.set_player(new_player)

	npc.queue_free()
	get_tree().current_scene.find_child("Switch_Characters").queue_free()

	camera.follow_target = new_player  # Smooth follow starts
	camera.reparent(new_player)
