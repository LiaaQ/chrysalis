extends CharacterBody2D

@export var attack_range := 200.0
@export var speed: float = 100.0
@export var hp_max: int = 400
@export var damage = 15
@export var attack_cooldown_init := 4.0
@export var teleport_cooldown_init := 20.0
@export var skill_cooldown_init := 15.0
@export var iframes_time: float = 1.5
@export var teleport_positions: Array[Vector2]
@export var skeleton_spawn_positions: Array[Vector2]
@export var chain_scene: PackedScene
@export var skeleton_scene: PackedScene
@export var phase2_threshold: float = 0.8
@export var phase3_threshold: float = 0.5

@onready var anim_tree: AnimationTree = $AnimationTree
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hp: int = hp_max

var attack_cooldown: float = attack_cooldown_init
var teleport_cooldown: float = teleport_cooldown_init
var skill_cooldown: float = skill_cooldown_init
var direction: Vector2
var distance: float
var skeletons: Array[CharacterBody2D]
var vulnerable = true
var player: CharacterBody2D

signal health_changed

func _ready():
	Game_Manager.connect("player_ready", Callable(self, "_on_player_ready"))
	hp = hp_max
	$Invulnerable.wait_time = iframes_time

func _process(delta):
	if not player:
		if Game_Manager.player != null:
			player = Game_Manager.player
		else: return
	distance = global_position.distance_to(player.global_position)
	
	if distance > 20.0:
		velocity = position.direction_to(player.position) * speed
		direction.x = sign(velocity.x)
	else:
		velocity = Vector2(0.0, 0.0)

	attack_cooldown -= delta
	teleport_cooldown -= delta
	skill_cooldown -= delta
	change_direction()
	
	if anim_tree["parameters/playback"].get_current_node() == "Idle":
		move_and_slide()
		
func change_direction():
	if direction.x == 1.0:
		sprite.scale.x = 1.0
		$UndeadDealDamage/CollisionShape2D.position.x = 55.0
		$UndeadHitbox/CollisionShape2D.position.x = 8.0
	elif direction.x == -1.0:
		sprite.scale.x = -1.0
		$UndeadDealDamage/CollisionShape2D.position.x = -55.0
		$UndeadHitbox/CollisionShape2D.position.x = -8.0
	
func perform_attack():
	attack_cooldown = attack_cooldown_init
	if randi() % 2 == 0:
		$Sounds/High_Attack.play()
		anim_tree["parameters/Attack/blend_position"] = 0.0
	else:
		$Sounds/Low_Attack.play()
		anim_tree["parameters/Attack/blend_position"] = 1.0

func teleport_near_player():
	teleport_cooldown = teleport_cooldown_init
	var closest = teleport_positions[0]
	var closest_dist = player.global_position.distance_to(closest)
	for pos in teleport_positions:
		var d = player.global_position.distance_to(pos)
		if d < closest_dist:
			closest = pos
			closest_dist = d
	global_position = closest

func skill():
	if skeletons.size() < 2:
		print("Spawning skeletons")
		anim_tree["parameters/Skill/blend_position"] = 0.0
		if float(hp) / float(hp_max) < phase2_threshold:
			summon_skeletons(1)
		elif float(hp) / float(hp_max) < phase3_threshold:
			summon_skeletons(2)
		else:
			summon_skeletons(3)
	else:
		throw_chain()
		print("Chaining")
		anim_tree["parameters/Skill/blend_position"] = 1.0

func summon_skeletons(amount: int):
	$Sounds/Summon.play()
	skill_cooldown = skill_cooldown_init

	var shuffled_positions = skeleton_spawn_positions.duplicate()
	shuffled_positions.shuffle()

	# Spawn only up to the requested amount or however many positions are available
	for i in range(amount):
		var skeleton = skeleton_scene.instantiate()
		skeleton.global_position = shuffled_positions[i]
		skeleton.boss = self
		get_parent().add_child(skeleton)
		skeletons.append(skeleton)

func remove_skeleton(skeleton: CharacterBody2D):
	if skeletons.has(skeleton):
		skeletons.erase(skeleton)

func throw_chain():
	skill_cooldown = skill_cooldown_init
	
	var chain = chain_scene.instantiate()
	var to_player = (player.global_position - global_position).normalized()
	chain.global_position = global_position
	chain.rotation = to_player.angle()
	chain.direction = to_player
	get_parent().add_child(chain)
	
	if float(hp) / float(hp_max) < phase3_threshold:
		for skeleton in skeletons:
			chain = chain_scene.instantiate()
			to_player = (player.global_position - skeleton.global_position).normalized()
			chain.global_position = skeleton.global_position
			chain.rotation = to_player.angle()
			chain.direction = to_player
			get_parent().add_child(chain)

func take_damage(incoming_damage: int):
	if vulnerable:
		hp -= incoming_damage
		health_changed.emit()
		$Invulnerable.start()
		vulnerable = false
		flash_white()

func _on_undead_deal_damage_body_entered(body: Node2D) -> void:
	if body.has_meta("type") and body.get_meta("type") == "player":
		body.take_damage(damage)

func death():
	Game_Manager.disconnect("player_ready", Callable(self, "_on_player_ready"))
	Dialogic.start("depression_win")
	for skeleton in skeletons:
		skeleton.hp = 0
		skeleton.health_changed.emit()
	queue_free()

func _on_invulnerable_timeout() -> void:
	vulnerable = true
	
func flash_white():
	while $Invulnerable.time_left > 0:
		sprite.material.set_shader_parameter("flash_white", true)
		await get_tree().create_timer(0.125).timeout
		sprite.material.set_shader_parameter("flash_white", false)
		await get_tree().create_timer(0.125).timeout
		
func _on_player_ready(p: CharacterBody2D) -> void:
	print("ready")
	player = p
	distance = global_position.distance_to(player.global_position)
