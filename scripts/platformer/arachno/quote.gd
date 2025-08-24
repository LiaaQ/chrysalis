extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D

@onready var offset_timer: Timer = $Start_offset
@onready var length_timer: Timer = $Length

@export var quote: String
@export var offset: int
@export var length: int
@export var label: Label

var fading_in := false
var fading_out := false

func _ready() -> void:
	offset_timer.wait_time = offset
	length_timer.wait_time = length

func _process(delta: float) -> void:
	if fading_in:
		label.modulate.a = clamp(label.modulate.a + delta, 0.0, 1.0)
	elif fading_out:
		label.modulate.a = clamp(label.modulate.a - delta, 0.0, 1.0)
		if label.modulate.a <= 0.0:
			if self.name == "12":
				get_tree().current_scene.return_back()
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		offset_timer.start()
		label.text = quote
		label.modulate.a = 0.0
		fading_in = false
		fading_out = false
		collision.queue_free()

func _on_start_offset_timeout() -> void:
	fading_in = true
	length_timer.start()

func _on_length_timeout() -> void:
	fading_in = false
	fading_out = true
