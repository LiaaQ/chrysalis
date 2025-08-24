extends Interactable

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var alive: bool = true

func _ready() -> void:
	if Game_Manager.killed_spiders >= 0.5 * Game_Manager.max_spiders:
		sprite.play("Death")
		alive = false

func _process(delta: float) -> void:
	if alive:
		if global_position.x >= 938:
			sprite.play("Walk")
			global_position.x -= delta * 20
		else:
			sprite.play("Idle")
