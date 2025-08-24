extends Node2D

@onready var level_1 = $Level1
@onready var dialogue_timeout = $Dialogue_Timeout
@onready var heartbeat_sound: AudioStreamPlayer = $General_Sounds/Heartbeat
@onready var heartbeat_bpm: Timer = $Heartbeat_BPM
@onready var fade_rect: ColorRect = $FadeRect

var checkpoints: Dictionary[String, String] = {
	"Depression_Platformer": "res://scenes/Platformer/Depression/platformer_depression.tscn",
	"Depression_Bossfight": "res://scenes/Platformer/Depression/platformer_depression_bossfight.tscn",
	"Depression_Room_After": "res://scenes/Top_Down/Phase1/room_after.tscn",
	"Arachnophobia_Platformer": "res://scenes/Platformer/Arachno/arachnophobia_platformer.tscn",
	"Arachnophobia_After": "res://scenes/Top_Down/outside_after_arachno.tscn",
	"Social_Platformer": "res://scenes/Platformer/Social/platformer_social.tscn",
	"Social_Bossfight": "res://scenes/Platformer/Social/platformer_social_bossfight.tscn",
	"Social_After": "res://scenes/Top_Down/outside_after_social.tscn",
	"OCD_Bossfight": "res://scenes/Platformer/OCD/platformer_ocd_bossfight.tscn",
	"OCD_After": "res://scenes/Top_Down/OCD/house2_after.tscn",
	"Nyctophobia_Platformer": "res://scenes/Platformer/Nycto/nyctophobia_platformer.tscn",
	"Nyctophobia_After": "res://scenes/Top_Down/nycto/Nycto_bedroom_after.tscn"
}

# General stuff
var curr_checkpoint = null
var pause_menu_instance: Control = null
var curr_song: AudioStreamPlayer = null

# Player related stuff
var player: CharacterBody2D = null
var movement_locked: bool = false
var interaction_locked: bool = false
var spawn_position: Vector2 = UNUSED_VECTOR

# Room state
var room_fixed_items: Array = []

# Bathroom state
var bathroom_fixed_items: Array = []
var roll_acquired: bool = false

# Arachnophobia level
var killed_spiders: int = 0
var max_spiders: int = 0

# OCD top-down
var ocd_entered_house: bool = false
var washed_hands: bool = false
var fixed_picture: bool = false
var worried_about_door: bool = false

# OCD bossfight
var first_coin_failed: bool = false
var first_coin_fixed: bool = false
var first_block_fixed: bool = false

const UNUSED_VECTOR := Vector2(-99999, -99999)

signal player_ready(player)

func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and Dialogic.current_timeline == null and get_tree().current_scene.name != "Main_Menu":
		if not get_tree().paused:
			load_menu()
			get_tree().paused = true
		else:
			if pause_menu_instance and pause_menu_instance.get_parent():
				pause_menu_instance.queue_free()
			get_tree().paused = false

func set_player(p: CharacterBody2D) -> void:
	player = p
	emit_signal("player_ready", player)

func _on_timeline_started():
	Dialogic.process_mode = Node.PROCESS_MODE_PAUSABLE
	movement_locked = true

func _on_timeline_ended():
	movement_locked = false
	dialogue_timeout.start()
	interaction_locked = true

func _on_dialogue_timeout_timeout() -> void:
	interaction_locked = false

func load_menu():
	pause_menu_instance = preload("res://scenes/UI/pause_menu.tscn").instantiate()
	pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	var pause_layer = CanvasLayer.new()
	pause_layer.layer = 10  # Higher = drawn on top
	pause_layer.add_child(pause_menu_instance)
	
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.add_child(pause_menu_instance)
	else:
		get_viewport().add_child(pause_menu_instance)
	get_tree().current_scene.add_child(pause_layer)

func _on_heartbeat_bpm_timeout() -> void:
	heartbeat_sound.play()

func load_checkpoint(checkpoint):
	if checkpoints.has(checkpoint):
		var scene = checkpoints[checkpoint]
		Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
		await Game_Manager.change_scene_fade_out(scene)
		
func change_scene_fade_out(new_scene_path: String):
	movement_locked = true
	interaction_locked = true
	var camera = get_viewport().get_camera_2d()
	if camera:
		fade_rect.global_position = camera.get_screen_center_position() + fade_rect.pivot_offset
	else:
		fade_rect.anchor_left = 0.5
		fade_rect.anchor_top = 0.5
		fade_rect.offset_left = -fade_rect.size.x / 2
		fade_rect.offset_top = -fade_rect.size.y / 2
	fade_rect.modulate.a = 0
	fade_rect.visible = true
	get_tree().current_scene.add_child(fade_rect)
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 1.0)
	await tween.finished
	
	get_tree().change_scene_to_file(new_scene_path)
	scene_fade_in()

func scene_fade_in():
	await get_tree().process_frame
	center_fade_rect()
	
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 1.0)
	await tween.finished
	
	fade_rect.visible = false
	interaction_locked = false
	movement_locked = false

func center_fade_rect() -> void:
	if get_viewport().get_camera_2d():
		fade_rect.global_position = get_viewport().get_camera_2d().get_screen_center_position()
	else:
		# Fallback centering if no camera
		fade_rect.anchor_left = 0.5
		fade_rect.anchor_top = 0.5
		fade_rect.offset_left = -fade_rect.size.x / 2
		fade_rect.offset_top = -fade_rect.size.y / 2

func reset_variables():
	var curr_checkpoint = null
	var pause_menu_instance = null
	var curr_song = null

	# Player related stuff
	var player = null
	var movement_locked = false
	var interaction_locked = false
	var spawn_position = UNUSED_VECTOR

	# Room state
	var room_fixed_items = []

	# Bathroom state
	var bathroom_fixed_items = []
	var roll_acquired = false

	# Arachnophobia level
	var killed_spiders = 0
	var max_spiders = 0

	# OCD top-down
	var ocd_entered_house = false
	var washed_hands = false
	var fixed_picture = false
	var worried_about_door = false

	# OCD bossfight
	var first_coin_failed = false
	var first_coin_fixed = false
	var first_block_fixed = false
