extends TextureProgressBar

@export var area: Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	if area:
		max_value = area.hp_max
		if not area.health_changed.is_connected(update):
			area.health_changed.connect(update)
		update()

func update():
	value = area.hp

func load():
	if area:
		max_value = area.hp_max
		if not area.health_changed.is_connected(update):
			area.health_changed.connect(update)
		update()
