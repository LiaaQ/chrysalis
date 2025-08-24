extends Node2D

@export var eye_scenes: Array[PackedScene] = []
@export var player: CharacterBody2D
@export var min_distance_to_despawn := 1000.0
@export var spawn_interval := 2.0

@onready var cooldown_timer: Timer = $Spawn_Cooldown

var eyes_in_scene := []

func _ready() -> void:
	cooldown_timer.wait_time = spawn_interval

func _on_spawn_cooldown_timeout() -> void:
	
	var camera = get_viewport().get_camera_2d()

	var top_left = camera.get_screen_center_position() - (get_viewport_rect().size / camera.zoom) / 2
	var bottom_right = camera.get_screen_center_position() + (get_viewport_rect().size / camera.zoom) / 2

	# Choose a random spawn position in view
	var spawn_x = randf_range(camera.get_screen_center_position().x, bottom_right.x)
	var spawn_y = randf_range(top_left.y, bottom_right.y)
	
	# Adjust spawn rate based on how far the player has progressed (e.g., rightward in level)
	var progress = get_tree().current_scene.progression
	var dynamic_interval = max(0.5, lerp(spawn_interval, spawn_interval * 0.3, progress))
	cooldown_timer.wait_time = dynamic_interval

	# Spawn a random eye
	var eye_scene = eye_scenes[randi() % eye_scenes.size()]
	if eye_scene.resource_path == "res://scenes/Platformer/Social/floating_eye_sad.tscn":
		spawn_y = randf_range(top_left.y, player.global_position.y)
		print(spawn_y)
	var eye_instance = eye_scene.instantiate()
	eye_instance.global_position = Vector2(spawn_x, spawn_y)
	add_child(eye_instance)
	eyes_in_scene.append(eye_instance)
