extends Interactable

@export var follow_speed = 5.0  # Speed at which the blob moves towards the target
@export var follow_distance = 10.0  # Distance threshold to stop moving
@export var offset: Vector2 = Vector2(-40.0, -10.0)

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Move

var player: CharacterBody2D
var target_position: Vector2
var is_following = false
var dir: Vector2 = Vector2(0, 1)

var fading_in := false
var fading_out := false

func _ready():
	Game_Manager.connect("player_ready", Callable(self, "_on_player_ready"))
	target_position = global_position  # Start with the blob's current position


func _process(delta):
	if fading_in:
		sprite.modulate.a = clamp(sprite.modulate.a + delta, 0.0, 1.0)
	elif fading_out:
		sprite.modulate.a = clamp(sprite.modulate.a - delta, 0.0, 1.0)
	if player:
		target_position = Vector2(player.global_position.x + offset.x, player.global_position.y + offset.y)
		if global_position != target_position and timer.is_stopped():
			timer.start()
		if is_following:
			move_to_target(delta)
	else: player = Game_Manager.player

func move_to_target(delta):
	if global_position.distance_to(target_position) > follow_distance:
		global_position = global_position.lerp(target_position, follow_speed * delta)
		change_sprite()
	else:
		is_following = false

func change_sprite():
	var player_velocity = (target_position - global_position).normalized()

	# Choose the animation based on the movement direction
	if abs(player_velocity.y) > abs(player_velocity.x):
		if player_velocity.y > 0:
			sprite.play("front")
		else:
			sprite.play("back")
	else:
		sprite.play("side")
		sprite.scale.x = 1 if player_velocity.x > 0 else -1

func _on_move_timeout() -> void:
	target_position = player.global_position
	is_following = true
	
func _on_player_ready(p: CharacterBody2D) -> void:
	player = p
	target_position = Vector2(player.global_position.x + offset.x, player.global_position.y + offset.y)

func interact():
	super()

func fade_out():
	fading_out = true
	fading_in = false
	
func fade_in():
	fading_out = false
	fading_in = true
