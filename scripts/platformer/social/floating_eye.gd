extends Area2D

@export var max_offset := Vector2(10, 6)
@export var queue_free_time: float = 8.0

@onready var eyeball = $Eyeball
@onready var anim_sprite = $Blink
@onready var cry_timer = $Timers/Cry_Timer
@onready var tear_timer = $Timers/Tear_Timer
@onready var tear_spawns: Array[Marker2D] = [$Tears_Spawn/Marker2D, $Tears_Spawn/Marker2D2, $Tears_Spawn/Marker2D3]
@onready var free_timer: Timer = $Timers/Free_Timer

var player: CharacterBody2D
var eyeball_center = Vector2.ZERO
var tear_scene := preload("res://scenes/Platformer/Social/tear.tscn")
var last_tear_spawn_idx = null
var crying: bool = false

func _ready() -> void:
	_on_cry_timer_timeout()
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

func get_new_tear_spawn_index() -> int:
	var new_index := randi() % tear_spawns.size()
	while new_index == last_tear_spawn_idx:
		new_index = randi() % tear_spawns.size()
	last_tear_spawn_idx = new_index
	return new_index

func _on_blink_timer_timeout() -> void:
	anim_sprite.play("blink")

func _on_cry_timer_timeout() -> void:
	crying = true
	tear_timer.start()
	await get_tree().create_timer(5.0).timeout
	crying = false
	tear_timer.stop()

func _on_tear_timer_timeout() -> void:
	if not crying: return
	
	var idx := get_new_tear_spawn_index()
	var pos := tear_spawns[idx].position
	var tear = tear_scene.instantiate()
	tear.position = pos
	tear.player = player
	$Tears.add_child(tear)

func take_damage(damage):
	queue_free()

func _on_free_timer_timeout() -> void:
	queue_free()
