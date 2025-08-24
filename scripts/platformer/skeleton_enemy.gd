extends CharacterBody2D

@onready var raycast_down: RayCast2D = $RayCastDown
@onready var raycast_wall: RayCast2D = $RayCastWall
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var attack_cooldown = attack_cooldown_init
@onready var hp: float = hp_max

@export var acceleration: float = 300
@export var speed: int = 50
@export var damage: int = 10
@export var hp_max: int = 50
@export var attack_range: int = 150
@export var iframes_time: float = 1.5
@export var attack_cooldown_init: float = 3.0
@export var boss: CharacterBody2D

var direction: Vector2 = Vector2(1.0, 0.0)
var new_dir: float
var distance: float
var player: CharacterBody2D
var vulnerable: bool = true

signal health_changed

func _ready() -> void:
	Game_Manager.connect("player_ready", Callable(self, "_on_player_ready"))
	if sprite.material:
		sprite.material = sprite.material.duplicate()
	$Timers/Invulnerable.wait_time = iframes_time

func _process(delta):
	if !is_on_floor():
		velocity += get_gravity() * delta
	if player:
		distance = global_position.distance_to(player.global_position)
	else: player = Game_Manager.player
		
	velocity = velocity.move_toward(direction * speed, acceleration * delta)
	attack_cooldown -= delta
	check_turn()
	if anim_tree["parameters/playback"].get_current_node() == "Walk" or not is_on_floor():
		move_and_slide()

func check_turn():
	if not raycast_down.is_colliding() and not direction.x == 0.0:
		new_dir = -direction.x
		direction.x = 0.0
		$Timers/Idle.start()
	elif raycast_wall.is_colliding():
		turn(-direction.x)

func _on_idle_timeout() -> void:
	turn(new_dir)

func turn(new_dir: int):
	direction.x = new_dir
	sprite.scale.x *= -1
	raycast_down.position.x *= -1
	raycast_wall.scale.x *= -1
	$SkeletonDealDamage/CollisionShape2D.position.x *= -1

func take_damage(incoming_damage: int):
	if vulnerable:
		hp -= incoming_damage
		anim_tree["parameters/conditions/hurting"] = true
		health_changed.emit()
		$Timers/Invulnerable.start()
		vulnerable = false
		flash_white()
	
func attack():
	if player:
		$Timers/Idle.stop()
		var dir_to_player = player.global_position.x - global_position.x
		
		# Check if facing the wrong way
		if (dir_to_player < 0 and sprite.scale.x > 0) or (dir_to_player > 0 and sprite.scale.x < 0):
			turn(dir_to_player / abs(dir_to_player))

	attack_cooldown = attack_cooldown_init
	
func death():
	if boss and boss.has_method("remove_skeleton"):
		boss.remove_skeleton(self)
	if get_tree().current_scene.has_method("player_power_up"):
		get_tree().current_scene.player_power_up()
	Game_Manager.disconnect("player_ready", Callable(self, "_on_player_ready"))
	queue_free()

func _on_skeleton_deal_damage_body_entered(body: Node2D) -> void:
	if body == player and body.has_method("take_damage"):
		body.take_damage(damage)

func _on_invulnerable_timeout() -> void:
	vulnerable = true

func flash_white():
	while $Timers/Invulnerable.time_left > 0:
		sprite.material.set_shader_parameter("flash_white", true)
		await get_tree().create_timer(0.125).timeout
		sprite.material.set_shader_parameter("flash_white", false)
		await get_tree().create_timer(0.125).timeout

func _on_player_ready(p: CharacterBody2D) -> void:
	player = p
	distance = global_position.distance_to(player.global_position)
