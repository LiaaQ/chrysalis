extends Node2D

@export var camera: Camera2D
@export var npc: CharacterBody2D

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)

func _process(delta: float) -> void:
	pass

func _dialogic_signal(arg):
	if arg == "social_platformer":
		Game_Manager.curr_checkpoint = "Social_Platformer"
		await Game_Manager.change_scene_fade_out("res://scenes/Platformer/Social/platformer_social.tscn")

func _on_switch_characters_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		call_deferred("_switch_character")

func _switch_character():
	Game_Manager.movement_locked = true
	Game_Manager.player.set_script(load("res://scripts/top_down/lockscene/ella_switch.gd"))
	Game_Manager.player._new_ready()
	
	var new_player = preload("res://scenes/Top_Down/player_top_down_2.tscn").instantiate()
	new_player.global_position = npc.global_position
	get_tree().current_scene.get_node("YSort").add_child(new_player)
	new_player.sprite.play("idle_front")
	Game_Manager.set_player(new_player)

	npc.queue_free()
	get_tree().current_scene.find_child("Switch_Characters").queue_free()

	camera.follow_target = new_player  # Smooth follow starts
	camera.reparent(new_player)
	Dialogic.start("social_anxiety_start")
	
