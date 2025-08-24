extends Node2D

@export var player: CharacterBody2D

func _ready() -> void:
	player.sprite.material.set_shader_parameter("saturation_level", 1.0)
	Dialogic.signal_event.connect(dialogic_signal)

func dialogic_signal(arg):
	if arg == "open_door":
		$Door_Open.visible = true
