extends Interactable

@export var before_sprite: Sprite2D
@export var after_sprite: Sprite2D
var manager_array: String

func _ready() -> void:
	super()
	manager_array = get_tree().current_scene.manager_array

func interact():
	if before_sprite and after_sprite:
		before_sprite.queue_free()
		after_sprite.visible = true
		var array
		if manager_array in Game_Manager:
			array = Game_Manager.get(manager_array)
		if array != null and get_path() not in array:
			array.append(get_path())
			Game_Manager.set(manager_array, array)
