extends Area2D

class_name Killzone

var checkpoint: Vector2
@export var fall_damage: int = 20

func _on_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		if not checkpoint:
			get_tree().reload_current_scene()
		else:
			body.global_position = checkpoint
			if "hp" in body:
				body.hp -= fall_damage
				body.health_changed.emit()
