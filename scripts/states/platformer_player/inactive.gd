extends State

class_name Inactive
signal action_finished

func enter():
	emit_signal("action_finished")

func update(_delta):
	if Input.is_action_just_pressed("attack"):
		return "Attack"
	if Input.is_action_just_pressed("defend"):
		return "Defend"
	return ""
