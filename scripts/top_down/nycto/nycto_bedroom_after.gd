extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@export var bed: Interactable
@export var sprite_sleeping: Sprite2D
@export var lights: Array[PointLight2D]
@export var companion: Interactable

func _ready() -> void:
	Dialogic.start("Nycto_After")
	Dialogic.signal_event.connect(_dialogic_signal)

func light():
	canvas_modulate.visible = false
	
func dark():
	canvas_modulate.visible = true

func _dialogic_signal(arg):
	if arg == "final_scene":
		await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/final_scene.tscn")
