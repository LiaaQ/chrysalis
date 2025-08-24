extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@export var bed: Interactable
@export var sprite_sleeping: Sprite2D
@export var lights: Array[PointLight2D]
@export var companion: Interactable

func _ready() -> void:
	companion.sprite.modulate.a = 0
	Dialogic.signal_event.connect(_dialogic_signal)

func _process(delta: float) -> void:
	if Game_Manager.player:
		Game_Manager.player.speed = 1

func light():
	canvas_modulate.visible = false
	
func dark():
	canvas_modulate.visible = true

func _dialogic_signal(arg):
	if arg == "lights_off":
		$CanvasModulate.visible = true
		for light in lights:
			light.visible = false
		if Game_Manager.curr_song:
			Game_Manager.curr_song.stop()
	if arg == "nycto_start":
		Game_Manager.curr_checkpoint = "Nyctophobia_Platformer"
		get_tree().change_scene_to_file("res://scenes/Platformer/Nycto/nyctophobia_platformer.tscn")
