extends Area2D

@export var fall_speed := 100.0
var player: CharacterBody2D

func _physics_process(delta):
	position.y += fall_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		if body.has_method("get_slowed"):
			body.get_slowed()

func _on_timeout_timeout() -> void:
	queue_free()
