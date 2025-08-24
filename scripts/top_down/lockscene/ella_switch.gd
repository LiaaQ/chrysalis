extends CharacterBody2D

var sprite: AnimatedSprite2D

func _new_ready():
	sprite = $AnimatedSprite2D
	velocity = Vector2(0, -1)
	sprite.play("run_back")

func _process(delta: float) -> void:
	if position.y < -1000:
		queue_free()
	velocity.y = -1
	# Normalize velocity to maintain consistent speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * 1.5

	position += velocity
	move_and_slide()
