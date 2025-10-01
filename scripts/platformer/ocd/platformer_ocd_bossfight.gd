extends Node2D

@onready var anxiety_bar: TextureProgressBar = $OCDAnxietyBar
@onready var coins_timer: Timer = $Coins_Timer
@onready var unaligned_timer: Timer = $Unaligned_Timer
@onready var ocd_hp: TextureProgressBar = $OCD_Hp

var unaligned_blocks: Array[UnalignedBlock] = []
var coin_areas: Array[CollisionShape2D]

var dialogue_triggers: Array = [0.0, 25.0, 50.0, 75.0, 99.0]  # Boss hp thresholds
var triggered_dialogues: Dictionary = {}  # Track triggered dialogues

var anxiety: float = 0.0
var anxiety_gain: float = 0.0
const MAX_ANXIETY: float = 100.0
const ANXIETY_BOX_FAIL: float = 5
const ANXIETY_COIN_FAIL: float = 10
const ANXIETY_BOX_SUCCESS: float = -7.5
const ANXIETY_COIN_SUCCESS: float = -10

func _ready() -> void:
	if Game_Manager.curr_song:
		Game_Manager.curr_song.stop()
	Dialogic.signal_event.connect(_dialogic_signal)
	anxiety_bar.value = 0.0
	unaligned_blocks = []
	for child in $Unaligned_Blocks.get_children():
		if child is UnalignedBlock:
			unaligned_blocks.append(child)
	for child in $Coin_Areas.get_children():
		if child is CollisionShape2D:
			coin_areas.append(child)
			
	for value in dialogue_triggers:
		triggered_dialogues[value] = false
	
	Dialogic.start("OCD_boss_introduction")

func _process(delta: float) -> void:
	
	if Dialogic.current_timeline == null and not Game_Manager.interaction_locked:
		for ocd_hp_threshold in dialogue_triggers:
			if ocd_hp.value <= ocd_hp_threshold and not triggered_dialogues[ocd_hp_threshold]:
				trigger_dialogue_for_threshold(ocd_hp_threshold)
		print(5*delta)
		if anxiety_bar.value >= 100.0:
			ocd_hp.value = max(0, ocd_hp.value - 5 * delta)
		anxiety_gain = clamp(anxiety_gain, -5, 5)
		update_anxiety(anxiety_gain * delta)
		if coins_timer.paused:
			coins_timer.paused = false
		if unaligned_timer.paused:
			unaligned_timer.paused = false
	else:
		coins_timer.paused = true
		unaligned_timer.paused = true

func trigger_dialogue_for_threshold(threshold):
	if threshold == 0.0:
		Dialogic.start("ocd_0")
	elif threshold == 25.0:
		Dialogic.start("ocd_25")
	elif threshold == 50.0:
		Dialogic.start("ocd_50")
	elif threshold == 75.0:
		Dialogic.start("ocd_75")
	elif threshold == 99.0:
		Dialogic.start("ocd_first_hit")
	
	# Mark this threshold as triggered
	triggered_dialogues[threshold] = true

func _on_unaligned_timer_timeout() -> void:
	unaligned_blocks.shuffle()
	var block = unaligned_blocks[0]
	unaligned_blocks.pop_front()
	var offset = get_random_offset()
	if offset < 0:
		block.ascend_sound.play()
	else:
		block.descend_sound.play()
	block.unalign(offset)
	anxiety_gain += ANXIETY_BOX_FAIL
	
func get_random_offset():
	var range = randf()
	if range < 0.5:
		return randi_range(-20, -10)
	else:
		return randi_range(10, 20)

func update_anxiety(amount: float) -> void:
	anxiety = clamp(anxiety + amount, 0, MAX_ANXIETY)
	anxiety_bar.value = anxiety

func _on_coins_timer_timeout() -> void:
	var coins = preload("res://scenes/Platformer/OCD/coins.tscn").instantiate()
	add_child(coins)
	coins.areas = coin_areas
	coins.amount = randi_range(2, 8)
	coins.spawn_coins()


func _dialogic_signal(arg):
	if arg == "delete_sprite":
		$AnimatedSprite2D.visible = false
	elif arg == "show_sprite":
		$AnimatedSprite2D.visible = true
	elif arg == "leave_scene":
		Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
		Game_Manager.curr_checkpoint = "OCD_After"
		Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
		await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/OCD/house2_after.tscn")
