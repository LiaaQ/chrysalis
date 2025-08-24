extends Node2D

var manager_array = "bathroom_fixed_items"

func _ready() -> void:
	var array = Game_Manager.bathroom_fixed_items
	for item in array:
		var object = get_node_or_null(item)
		if object and object.has_method("interact"):
			object.interact()
