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

# Chain attack
@export var hbox: HBoxContainer
var sequence_idx: int = 0
var chain_sequence: Array[String]

var hp: int = hp_max
var direction := Input.get_axis("left", "right")
var chained: bool = false
var vulnerable: bool = true

signal health_changed

func _ready() -> void:
	anim_tree.active = true
	hp = hp_max
	Game_Manager.set_player(self)
	sprite.material.set_shader_parameter("flash_white", false)

func _physics_process(delta):
	var target_speed = run_speed if Input.is_action_pressed("sprint") else walk_speed
	if not is_on_floor():
			velocity += get_gravity() * delta

	if hp <= 0:
		get_tree().create_timer(1.0).timeout
		get_tree().reload_current_scene()

	if not Game_Manager.movement_locked and not chained:
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
		
		#defending = true if Input.is_action_pressed("defend") else false

		if Input.is_action_just_pressed("attack"):
			anim_tree["parameters/conditions/attacking"] = true
		if Input.is_action_just_released("attack"):
			anim_tree["parameters/conditions/attacking"] = false
		
		if direction != 0 and hp > 0:
			sprite.flip_h = direction < 0
			$PlayerDealDamage/CollisionShape2D.position.x = abs($PlayerDealDamage/CollisionShape2D.position.x) * (-1 if direction < 0 else 1)
	else:
		velocity.x = 0
	move_and_slide()
		
func take_damage(incoming_damage: int):
	if vulnerable:
		hp -= incoming_damage
		health_changed.emit()
		vulnerable = false
		$Invulnerable.start()
		flash_white()

func get_chained(sequence: Array[String]):
	chained = true
	chain_sequence = sequence
	
func _input(event: InputEvent) -> void:
	if chained and event is InputEventKey and event.is_pressed():
		var pressed_key := OS.get_keycode_string(event.keycode).to_lower()
		check_chain_input(pressed_key)

func check_chain_input(key: String):
	if key == chain_sequence[sequence_idx]:
		sequence_idx += 1
		if sequence_idx >= chain_sequence.size():
			chained = false
			chain_sequence.clear()
			sequence_idx = 0
			for child in hbox.get_children():
				child.queue_free()
			return
	else:
		sequence_idx = 0
	
	update_chain_ui(sequence_idx)

func update_chain_ui(index: int):
	if index != 0:
		var texture_rect = hbox.get_child(index-1)
		texture_rect.modulate = Color(29 / 255.0, 1, 139 / 255.0)
	else:
		for i in hbox.get_child_count():
			var texture_rect = hbox.get_child(i)
			texture_rect.modulate = Color(1, 1, 1)

func _on_player_deal_damage_area_entered(area: Area2D) -> void:
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)

func _on_vulnerable_timeout() -> void:
	vulnerable = true

func flash_white():
	while $Invulnerable.time_left > 0:
		sprite.material.set_shader_parameter("flash_white", true)
		await get_tree().create_timer(0.125).timeout
		sprite.material.set_shader_parameter("flash_white", false)
		await get_tree().create_timer(0.125).timeout
