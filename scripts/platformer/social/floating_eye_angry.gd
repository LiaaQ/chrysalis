extends Area2D

@export var max_offset := Vector2(10, 6)
@export var queue_free_time: float = 8.0

@onready var eyeball = $Eyeball
@onready var anim_sprite = $Blink
@onready var attack_timer = $Timers/Attack_Timer
@onready var missile_timer = $Timers/Missile_Timer
@onready var free_timer = $Timers/Free_Timer

var player: CharacterBody2D
var eyeball_center = Vector2.ZERO
var missile_scene := preload("res://scenes/Platformer/Social/missile.tscn")

func _ready() -> void:
	free_timer.wait_time = queue_free_time
	free_timer.start()
	player = Game_Manager.player
	anim_sprite.play("open")
	_on_attack_timer_timeout()

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
	if player:
		var to_player = (player.global_position - global_position).normalized()
		var missile = missile_scene.instantiate()
		missile.global_position = eyeball_center
		missile.velocity = to_player * missile.speed
		missile.rotation = to_player.angle()
		add_child(missile)
	
	missile_timer.start()
	await get_tree().create_timer(1.5).timeout
	missile_timer.stop()

func _on_missile_timer_timeout() -> void:
	if player:
		var to_player = (player.global_position - global_position).normalized()
		var missile = missile_scene.instantiate()
		missile.global_position = eyeball_center
		missile.velocity = to_player * missile.speed
		missile.rotation = to_player.angle()
		missile.player = player
		add_child(missile)

func _on_free_timer_timeout() -> void:
	queue_free()

func take_damage(damage):
	queue_free()
