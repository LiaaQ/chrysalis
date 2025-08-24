extends Interactable

var toggle: int = 0
var root: Node2D

func _ready() -> void:
	super()
	root = get_tree().current_scene

func interact():
	super()
	if toggle == 0:
		root.light()
	else:
		root.dark()
	toggle = (toggle + 1) % 2
