extends State

class_name Attack

var attacking: bool = false
var attack_type: String

func enter():
	parent.sprite.play("Attack1")
	# Connect the signal to a function when the attack animation is finished
	if not parent.sprite.is_connected("animation_finished", Callable(self, "_on_animation_finished")):
		parent.sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func update(_delta):
	if not parent.sprite.animation == "Attack1":
		return "Inactive"
	return ""

func _on_animation_finished():
	if parent.sprite.animation == "Attack1":  # Check if it's the attack animation
		parent.state_machine_action.transition_to("Inactive")
