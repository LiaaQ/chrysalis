extends Area2D

@export var speed := 300.0
var velocity := Vector2.ZERO
var damage = 10
var player: CharacterBody2D

func _process(delta):
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	if body == player:
		body.take_damage(damage)
		queue_free()
	elif body is TileMapLayer:
		queue_free()

func _on_timeout_timeout() -> void:
	queue_free()
