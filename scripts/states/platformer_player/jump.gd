extends State

var jump_timer

func enter():
	parent.sprite.play("Jump")
	jump_timer = 0.2

func update(delta: float) -> String:
	if jump_timer > 0:
		jump_timer -= delta
		return ""
		
	print(parent.velocity.y)
	
	var direction := Input.get_axis("left", "right")
	if parent.is_on_floor() and parent.velocity.y >= 0:
		if direction != 0:
			return "Run"  # Transition to running if on the ground and running
		else:
			return "Idle"  # Transition to walking if on the ground and not running

	return ""

func physics_update(delta: float) -> String:
	if Input.is_action_just_pressed("jump") and (parent.is_on_floor() or parent.is_on_wall()):
		parent.velocity.y = parent.jump_force

	if Input.is_action_just_released("jump") and parent.velocity.y < 0:
		parent.velocity.y *= parent.decelerate_on_jump_release

	return ""
