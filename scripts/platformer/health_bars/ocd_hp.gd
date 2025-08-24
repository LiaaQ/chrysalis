extends TextureProgressBar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	update(0)

func update(amount: float):
	print("Updating OCD HP by", amount)
	value += amount
	print("New value:", value)
