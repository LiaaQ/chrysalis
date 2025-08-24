extends State

class_name Idle

func enter():
	if parent.state_machine_action.current_state is Inactive:
		parent.sprite.play("Idle")
	parent.state_machine_action.get_node("Inactive").connect("action_finished", Callable(self, "_on_action_finished"))

func exit():
	if parent.sprite.animation_finished.is_connected(self._on_action_finished):
		parent.sprite.animation_finished.disconnect(self._on_action_finished)
	
	if parent.state_machine_action.get_node("Inactive").is_connected("action_finished", Callable(self, "_on_action_finished")):
		parent.state_machine_action.get_node("Inactive").disconnect("action_finished", Callable(self, "_on_action_finished"))		

func update(delta: float) -> String:
	var direction := Input.get_axis("left", "right")
	if direction != 0 or Input.is_action_just_pressed("jump"):
		return "Move"  # Transition to the walking state

	return ""
	
func physics_update(delta: float) -> String:
	# Handle deceleration when idle
	var velocity_x = parent.velocity.x
	if velocity_x != 0:
		parent.velocity.x = move_toward(velocity_x, 0, parent.walk_speed * parent.deceleration)

	return ""

func _on_action_finished():
	parent.sprite.play("Idle")
