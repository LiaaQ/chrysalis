extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_tree: AnimationTree = $AnimationTree

# Jumping
@export var jump_force = -650.0
@export_range(0, 1) var decelerate_on_jump_release = 0.5

# Running
@export var walk_speed = 200.0
@export var run_speed = 300.0
@export_range(0, 1) var deceleration = 0.08
@export_range(0, 1) var acceleration = 0.1

var direction := Input.get_axis("left", "right")

func _ready() -> void:
	anim_tree.active = true
	Game_Manager.set_player(self)

func _physics_process(delta):
	var target_speed = run_speed if Input.is_action_pressed("sprint") else walk_speed
	if not is_on_floor():
			velocity += get_gravity() * delta

	if not Game_Manager.movement_locked:
		direction = Input.get_axis("left", "right")

		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * target_speed, target_speed * acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, target_speed * deceleration)

		if Input.is_action_pressed("jump") and is_on_floor():
			velocity.y = jump_force
		elif Input.is_action_just_released("jump") and velocity.y < 0:
			velocity.y *= decelerate_on_jump_release
	
		if direction != 0:
			sprite.flip_h = direction < 0
	else:
		velocity.x = 0
	move_and_slide()
