extends Node2D

@export var camera: Camera2D
@export var companion: Interactable

var spider_area_entered: bool = false

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)
	companion.sprite.modulate.a = 0

func _process(delta: float) -> void:
	if spider_area_entered:
		if camera.offset.y >= -50:
			camera.offset.y -= 20 * delta
		elif Dialogic.current_timeline == null:
			Dialogic.start("spider_topdown")
			spider_area_entered = false
			companion.fade_in()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		if Game_Manager.curr_song:
			Game_Manager.curr_song.stop()
		Game_Manager.heartbeat_bpm.wait_time = 1.0
		Game_Manager.heartbeat_bpm.start()
		spider_area_entered = true
		Game_Manager.movement_locked = true
		
func _dialogic_signal(arg):
	if arg == "arachno_start":
		Game_Manager.heartbeat_bpm.stop()
		Game_Manager.curr_checkpoint = "Arachnophobia_Platformer"
		await Game_Manager.change_scene_fade_out("res://scenes/Platformer/Arachno/arachnophobia_platformer.tscn")
