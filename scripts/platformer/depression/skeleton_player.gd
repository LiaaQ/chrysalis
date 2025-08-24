extends CharacterBody2D

class_name SkeletonPlayer

@export var speed = 100.0

@export_range(0, 1) var deceleration = 0.08
@export_range(0, 1) var acceleration = 0.1

@onready var anim_tree = $AnimationTree

var direction := Input.get_axis("left", "right")
var dead: bool = false
var interactions: Array[String]

func _ready() -> void:
	Game_Manager.set_player(self)

func _process(delta: float) -> void:
	if not dead:
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		if not Game_Manager.movement_locked:
			
			if not Game_Manager.interaction_locked:
				if Input.is_action_just_pressed("jump"):
					Dialogic.start("skeleton_jump")
					if not interactions.has("jump"):
						interactions.append("jump")
				elif Input.is_action_just_pressed("attack"):
					Dialogic.start("skeleton_attack")
					if not interactions.has("attack"):
						interactions.append("attack")

			if interactions.size() >= 2 and Dialogic.current_timeline == null:
				Dialogic.start("skeleton_transform")
		
			direction = Input.get_axis("left", "right")
			if direction != 0:
				$AnimatedSprite2D.flip_h = direction < 0
				velocity.x = move_toward(velocity.x, direction * speed, speed * acceleration)
			else:
				velocity.x = move_toward(velocity.x, 0, speed * deceleration)
		else:
			velocity.x = 0
			$AnimatedSprite2D
		move_and_slide()
