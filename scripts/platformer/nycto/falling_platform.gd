@tool
extends StaticBody2D

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var offset_timer: Timer = $offset
@onready var length_timer: Timer = $length
@onready var sprite: Sprite2D = $Sprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D

@export var speed: float = 400.0
@export var texture: Texture2D:
	set(value):
		texture = value
		if sprite:
			sprite.texture = texture

var original_pos: Vector2
var falling: bool = false

func _ready() -> void:
	sprite.texture = texture
	original_pos = global_position
	
func _process(delta: float) -> void:
	if not length_timer.is_stopped():
		shake()
	elif falling:
		global_position.y += delta * speed
		if global_position.y >= original_pos.y + 1500:
			global_position = original_pos
			falling = false
			sound.stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player and not falling and length_timer.is_stopped():
		offset_timer.start()

func _on_offset_timeout() -> void:
	length_timer.start()
	sound.play()

func shake():
	var shake_offset = Vector2(
		randf_range(-2, 2),
		randf_range(-1, 1)
	)
	global_position = original_pos + shake_offset
	
func _notification(what):
	if what == NOTIFICATION_ENTER_TREE:
		var sprite = $Sprite2D if has_node("Sprite2D") else null
		if sprite and texture:
			sprite.texture = texture

func _on_length_timeout() -> void:
	falling = true
