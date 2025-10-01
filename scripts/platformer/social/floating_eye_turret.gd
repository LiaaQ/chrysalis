extends Area2D

@export var max_offset := Vector2(10, 6)
@export var queue_free_time: float = 8.0

@onready var eyeball = $Eyeball
@onready var anim_sprite = $Blink
@onready var attack_timer = $Timers/Attack_Timer
@onready var free_timer = $Timers/Free_Timer

var player: CharacterBody2D
var eyeball_center = Vector2.ZERO
var missile_scene := preload("res://scenes/Platformer/Social/missile.tscn")

func _ready() -> void:
	_on_attack_timer_timeout()
	free_timer.wait_time = queue_free_time
	free_timer.start()
	player = Game_Manager.player
	anim_sprite.play("open")

func _process(delta: float) -> void:
	if player:
		var to_player = (player.global_position - global_position)
		var dir = to_player.normalized()
		var offset = Vector2(
			clamp(dir.x * abs(to_player.x), -max_offset.x, max_offset.x),
			clamp(dir.y * abs(to_player.y), -max_offset.y, max_offset.y)
		)
		eyeball.position = eyeball_center + offset
	else:
		eyeball.position = eyeball_center

func _on_blink_timer_timeout() -> void:
	anim_sprite.play("blink")

func _on_attack_timer_timeout() -> void:
	if not player: return
	
	var to_player = (player.global_position - global_position).normalized()
	var spread = 0.2
	
	for i in [-1, 0, 1]:
		var missile = missile_scene.instantiate()
		var angle_offset = i * spread
		var rotated_dir = to_player.rotated(angle_offset)
		missile.global_position = eyeball_center
		missile.velocity = rotated_dir * missile.speed
		missile.rotation = rotated_dir.angle()
		missile.player = player
		$Missiles.add_child(missile)

func _on_free_timer_timeout() -> void:
	queue_free()

func take_damage(damage):
	queue_free()
