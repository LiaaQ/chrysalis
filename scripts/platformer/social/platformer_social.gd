extends Node2D

@export var player: CharacterBody2D

@export var whisper_interval: float = 4.0
@export var progression_threshold: float = 0.5
@export var use_weighted_gender: bool = true
@export var level_start: float = 0.0
@export var level_end: float

var male_early_whispers: Array = []
var male_late_whispers: Array = []
var female_early_whispers: Array = []

var male_early_pool: Array = []
var male_late_pool: Array = []
var female_early_pool: Array = []

var time_accumulator: float = 0.0
var progression: float = 0.0 # 0.0 to 1.0

func _ready():
	if Game_Manager.curr_song:
		Game_Manager.curr_song.stop()
	load_whispers()
	level_end = $EndLight.global_position.x
	Dialogic.start("social_platformer_start")
	Dialogic.signal_event.connect(_dialogic_signal)

func _process(delta):
	if not player:
		return
	progression = clamp((player.position.x - level_start) / (level_end - level_start), 0.0, 1.0)
	time_accumulator += delta

	# Whisper frequency increases as you go further right
	var dynamic_interval = lerp(whisper_interval, whisper_interval * 0.3, progression)

	if time_accumulator >= dynamic_interval:
		time_accumulator = 0.0
		play_random_whisper()

func load_whispers():
	_load_whispers_from($Male_Whispers, male_early_whispers)
	_load_whispers_from($Male_Talking, male_late_whispers)
	_load_whispers_from($Female_Whispers, female_early_whispers)

# Loads the resources from the given ResourcePreloader
func _load_whispers_from(preloader: ResourcePreloader, into_array: Array):
	for resource in preloader.get_resource_list():
		into_array.append(preloader.get_resource(resource))

func play_random_whisper():
	var source_pool := []
	check_pools()
	var use_male = randf() < 0.7 if use_weighted_gender else randi() % 2 == 0
	if progression < progression_threshold:
		if use_male:
			source_pool = male_early_pool
		else:
			source_pool = female_early_pool
	else:
		if use_male:
			source_pool = male_late_pool + male_early_pool
		else: source_pool = female_early_pool

	if source_pool.is_empty():
		return

	var selected = source_pool.pick_random()
	source_pool.erase(selected)

	var audio = AudioStreamPlayer.new()
	add_child(audio)
	if use_male:
		audio.volume_db = 0 + randf_range(-4, 4)  # louder base
	else:
		audio.volume_db = -8 + randf_range(-4, 4)  # softer base
	audio.stream = selected
	audio.bus = "Whispers"
	audio.play()
	audio.finished.connect(audio.queue_free)

func check_pools():
	if male_late_pool.is_empty():
		male_late_pool = male_late_whispers.duplicate()
	if female_early_pool.is_empty():
		female_early_pool = female_early_whispers.duplicate()
	if male_early_pool.is_empty():
		male_early_pool = male_early_whispers.duplicate()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player:
		var camera = get_viewport().get_camera_2d()
		camera.reparent(get_tree().current_scene)
		camera.global_position = Vector2(13057.0, 382.0)


func _on_new_level_body_entered(body: Node2D) -> void:
	if body == player:
		Game_Manager.curr_checkpoint = "Social_Boss"
		await Game_Manager.change_scene_fade_out("res://scenes/Platformer/Social/platformer_social_bossfight.tscn")

func _dialogic_signal(arg):
	if arg == "start_spawning_eyes":
		$EyeSpawner.cooldown_timer.start()
