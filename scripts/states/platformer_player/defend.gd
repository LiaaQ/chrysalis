extends State

class_name Defend

signal action_finished

func enter():
	parent.sprite.play("Defend")
	
func update(_delta):
	if not Input.is_action_pressed("defend"):
		return "Inactive"
	return ""
