extends CharacterBody2D

# Movement speed
@export var speed: float = 2

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var raycast: RayCast2D = $Interaction

var interactable: Interactable = null

func _ready() -> void:
	Game_Manager.set_player(self)
	if Game_Manager.spawn_position != Game_Manager.UNUSED_VECTOR:
		global_position = Game_Manager.spawn_position

func _physics_process(delta: float) -> void:
	# Reset velocity
	var velocity = Vector2.ZERO
	
	if not Game_Manager.movement_locked:
		# Input handling for movement
		if Input.is_action_pressed("up"):
			velocity.y -= 1
			sprite.play("run_back")
			raycast.target_position = Vector2(0, -20)
		elif Input.is_action_pressed("down"):
			velocity.y += 1
			sprite.play("run_front")
			raycast.target_position = Vector2(0, 20)
		elif Input.is_action_pressed("left"):
			velocity.x -= 1
			raycast.target_position = Vector2(-20, 0)
			sprite.play("run_left")
		elif Input.is_action_pressed("right"):
			velocity.x += 1
			raycast.target_position = Vector2(20, 0)
			sprite.play("run_right")
		else:
			# Play idle animations based on the last direction
			if sprite.animation.begins_with("run"):
				sprite.play("idle_" + sprite.animation.split("_")[1])

		# Normalize velocity to maintain consistent speed
		if velocity.length() > 0:
			velocity = velocity.normalized() * speed
		position += velocity

		move_and_slide()
	else:
		if sprite.animation.begins_with("run"):
				sprite.play("idle_" + sprite.animation.split("_")[1])
	
func _process(delta: float) -> void:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider:
			if collider is Area2D:
				collider = collider.get_parent()
			if interactable != collider and collider.has_method("interact"):
				interactable = collider
				if interactable.instant_trigger:
					interactable.interact()
	else:
		interactable = null
	if interactable and Input.is_action_just_pressed("interact") and not Game_Manager.interaction_locked and Dialogic.current_timeline == null:
		interactable.interact()
