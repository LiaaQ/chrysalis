extends Node

@export var initial_state: NodePath
var current_state: State

func _ready():
	await get_tree().process_frame
	
	current_state = get_node(initial_state)
	current_state.enter()

func _process(delta):
	if current_state:
		var next = current_state.update(delta)
		transition_to(next)

func _physics_process(delta):
	if current_state:
		var next = current_state.physics_update(delta)
		transition_to(next)

func transition_to(next_state_name: String):
	if not next_state_name or next_state_name.strip_edges() == "":
		return
	
	var next_state = find_child(next_state_name, true, false)  # Recursive search
	if next_state and next_state != current_state:
		current_state.exit()
		current_state = next_state
		current_state.enter()
