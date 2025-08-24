extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var active_timer: Timer = $Active
@onready var light: PointLight2D = $PointLight2D

@export var light_scale_max: float = 60.0
@export var light_scale_min: float = 1.0

var activated: bool = true

func _ready() -> void:
	sprite.play("start")

func _process(delta: float) -> void:
	if activated:
		light.texture_scale = lerp(light.texture_scale, light_scale_max, delta * 2.0)
	else:
		light.texture_scale = lerp(light.texture_scale, light_scale_min, delta * 2.0)

func _on_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player and not activated:
		activated = true
		sprite.play("start")

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "start":
		sprite.play("loop")

func _on_active_timeout() -> void:
	activated = false
	sprite.play("end")

func _on_body_exited(body: Node2D) -> void:
	if body == Game_Manager.player:
		active_timer.start()
