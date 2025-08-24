extends TextureProgressBar

@export var player: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	if player:
		max_value = player.hp_max
		if not player.health_changed.is_connected(update):
			player.health_changed.connect(update)
		update()

func update():
	value = player.hp

func load():
	if player:
		max_value = player.hp_max
		if not player.health_changed.is_connected(update):
			player.health_changed.connect(update)
		update()
