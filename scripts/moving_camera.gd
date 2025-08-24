extends Camera2D

var follow_target: Node2D = null

@export var speed: float = 200

func _process(delta):
	if follow_target:
		Game_Manager.movement_locked = true
		var direction = (follow_target.global_position - global_position).normalized()
		var distance = speed * delta
		var new_position = global_position + direction * distance

		# Stop if we're going to overshoot
		if global_position.distance_to(follow_target.global_position) < distance:
			global_position = follow_target.global_position
			follow_target = null  # Reached destination
			Game_Manager.movement_locked = false
		else:
			global_position = new_position
