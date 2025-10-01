extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@export var bed: Interactable
@export var sprite_sleeping: Sprite2D

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)
	if not Game_Manager.washed_hands:
		bed.dialogic_timeline = "ocd_bed_unwashed_hands"
	elif Game_Manager.washed_hands and not Game_Manager.worried_about_door:
		bed.dialogic_timeline = "bed_lock_door"
	else:
		bed.dialogic_timeline = "nycto_bed"

func light():
	canvas_modulate.visible = false
	
func dark():
	canvas_modulate.visible = true

func _dialogic_signal(arg):
	if arg == "get_up":
		if sprite_sleeping:
			sprite_sleeping.visible = false
		Game_Manager.player.visible = true
		Game_Manager.movement_locked = false
		Game_Manager.interaction_locked = false
		Game_Manager.worried_about_door = true
