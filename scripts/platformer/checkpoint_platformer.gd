extends Area2D

@export var killzone: Killzone

var collision: CollisionShape2D

func _ready() -> void:
	if not killzone:
		if get_tree().current_scene.has_node("Killzone"):
			killzone = get_tree().current_scene.get_node("Killzone")

func _on_body_entered(body):
	if body == Game_Manager.player:
		if killzone:
			killzone.checkpoint = global_position
			queue_free()
