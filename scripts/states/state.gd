extends Node
class_name State

@export var next_states: Array[NodePath] = []
var parent

func _ready() -> void:
	parent = get_parent().get_parent()

func enter():
	pass

func exit():
	pass

func update(_delta: float) -> String:
	return ""

func physics_update(_delta: float) -> String:
	return ""
