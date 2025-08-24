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

# Combat
@export var damage: int = 20
@export var hp_max: int = 100

var hp: int = hp_max
var direction := Input.get_axis("left", "right")
var can_sprint: bool = false
var vulnerable: bool = true
var slowed: bool = false

signal health_changed

func _ready() -> void:
	anim_tree.active = true
	hp = hp_max
	Game_Manager.set_player(self)
	sprite.material.set_shader_parameter("flash_white", false)

func _physics_process(delta):
	var target_speed
	if can_sprint:
		target_speed = run_speed if Input.is_action_pressed("sprint") else walk_speed
	else: target_speed = walk_speed
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * target_speed, target_speed * acceleration)
	else:
		velocity.x = move_toward(velocity.x, 0, target_speed * deceleration)

	if Input.is_action_pressed("jump") and is_on_floor():
		anim_tree["parameters/conditions/can_jump"] = true
		velocity.y = jump_force
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release

	if Input.is_action_just_pressed("attack"):
		anim_tree["parameters/conditions/attacking"] = true
	if Input.is_action_just_released("attack"):
		anim_tree["parameters/conditions/attacking"] = false
	
	if direction != 0 and hp > 0:
		$AnimatedSprite2D.flip_h = direction < 0
		$PlayerDealDamage/CollisionShape2D.position.x = abs($PlayerDealDamage/CollisionShape2D.position.x) * (-1 if direction < 0 else 1)
	
	if hp > 0:
		move_and_slide()
	else: get_tree().reload_current_scene()
		
func take_damage(incoming_damage: int):
	if vulnerable:
		hp -= incoming_damage
		health_changed.emit()
		vulnerable = false
		$Invulnerable.start()
		flash_white()

func _on_player_deal_damage_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		print("Dealing")
		area.take_damage(damage)
	elif area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
		
func get_slowed():
	$Slow.start()
	if not slowed:
		run_speed *= 0.5
		walk_speed *= 0.5
	slowed = true
	
func _on_vulnerable_timeout() -> void:
	vulnerable = true

func flash_white():
	while $Invulnerable.time_left > 0:
		sprite.material.set_shader_parameter("flash_white", true)
		await get_tree().create_timer(0.125).timeout
		sprite.material.set_shader_parameter("flash_white", false)
		await get_tree().create_timer(0.125).timeout

func _on_slow_timeout() -> void:
	slowed = false
	run_speed *= 2
	walk_speed *= 2
