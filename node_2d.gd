extends Node2D

@export var follow_speed = 5.0    # Speed at which the ball moves towards the player
@export var follow_distance = 10.0  # Minimum distance to stop moving
@export var idle_threshold = 0.1   # Speed threshold to detect if the player is idle

var player: Node2D
var is_idle = false

func _ready():
	player = get_parent()

func _process(delta):
	if player:
		_follow_player(delta)

func _follow_player(delta):
	# Get the player's movement direction and position
	var distance_to_player = global_position.distance_to(player.global_position)
	var player_velocity = player.get("velocity")  # Assumes the player has a "velocity" property

	# If the player is idle and the glowing ball is close enough, go to idle animation
	if distance_to_player <= follow_distance and player_velocity.length() < idle_threshold:
		if not is_idle:
			_set_idle_state()
	else:
		_move_towards_player(delta)
		if is_idle:
			_exit_idle_state()

func _move_towards_player(delta):
	# Smoothly move the glowing ball towards the player
	global_position = global_position.lerp(player.global_position, follow_speed * delta)

func _set_idle_state():
	is_idle = true
	$AnimationPlayer.play("idle")  # Assumes you have an idle animation in an AnimationPlayer

func _exit_idle_state():
	is_idle = false
	$AnimationPlayer.play("move_side")  # Switch back to a moving animation if applicable
