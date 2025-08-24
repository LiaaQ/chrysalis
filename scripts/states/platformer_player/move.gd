extends State

var curr_sprite: String = ""
var is_jumping: bool = false

func enter():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		if parent.state_machine_action.current_state is Inactive:
			parent.sprite.play("Run")
			curr_sprite = "Run"
	else:
		if parent.state_machine_action.current_state is Inactive:
			parent.sprite.play("Jump")
			curr_sprite = "Jump"
		is_jumping = true
	
	parent.state_machine_action.get_node("Inactive").connect("action_finished", Callable(self, "_on_action_finished"))

func exit():
	if parent.state_machine_action.get_node("Inactive").is_connected("action_finished", Callable(self, "_on_action_finished")):
		parent.state_machine_action.get_node("Inactive").disconnect("action_finished", Callable(self, "_on_action_finished"))		

func update(delta: float) -> String:
	var direction := Input.get_axis("left", "right")
	
	if is_jumping and parent.is_on_floor():
		if parent.state_machine_action.current_state is Inactive:
			parent.sprite.play("Run")
			curr_sprite = "Run"
			is_jumping = false
	
	if (direction == 0 and abs(parent.velocity.x) < 5) and parent.is_on_floor() and not Input.is_action_pressed("jump"):
		return "Idle"
	
	return ""

func physics_update(delta: float) -> String:
	var target_speed: float
	
	target_speed = set_speed()
	move(target_speed)
		
	if Input.is_action_pressed("jump") and parent.is_on_floor():
		is_jumping = true
		jump()
		
	if Input.is_action_just_released("jump"):
		fall()
	
	return ""

func set_speed():
	if Input.is_action_pressed("sprint"):
		return parent.run_speed
	else:
		return parent.walk_speed
		
func move(target_speed):
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		parent.velocity.x = move_toward(parent.velocity.x, direction * target_speed, target_speed * parent.acceleration)
	else:
		parent.velocity.x = move_toward(parent.velocity.x, 0, target_speed * parent.deceleration)
		
func jump():
	if parent.is_on_floor() or parent.is_on_wall():
		parent.velocity.y = parent.jump_force
		if parent.state_machine_action.current_state is Inactive:
			parent.sprite.stop()
			parent.sprite.play("Jump")
			curr_sprite = "Jump"

func fall():
	if parent.velocity.y < 0:
		parent.velocity.y *= parent.decelerate_on_jump_release
	
func _on_action_finished():
	parent.sprite.play(curr_sprite)
