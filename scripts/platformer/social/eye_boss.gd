extends Area2D

@export var hp_max: int = 300
@export var player: CharacterBody2D
@export var max_offset := Vector2(10, 6)
@export var camera: Camera2D

@onready var eyeball: Sprite2D = $Eyeball
@onready var anim_tree: AnimationTree = $AnimationTree
@onready var tears_timer: Timer = $Crying/Time_Between_Tears
@onready var turret_timer: Timer = $Turret/turret_shot
@onready var angry_timer: Timer = $Angry/angry_shot
@onready var collision: CollisionShape2D = $CollisionShape2D

# States
var vulnerable: bool = false
var angry: bool = false
var sad: bool = false
var turret: bool = false

var iframes: bool = false
var flashing: bool = false

var eyeball_center = Vector2.ZERO

var states: Array[String] = ["vulnerable", "angry", "sad", "turret"]
var states_pool: Array[String] = []
var stage: int = 1
var hp: int = hp_max

# Tears
var tear_spawn_locations: Array[Vector2]
var tear_spawn_pool: Array[Vector2] = []
var tear_scene := preload("res://scenes/Platformer/Social/tear.tscn")

# Combat
var missile_scene := preload("res://scenes/Platformer/Social/missile.tscn")

signal health_changed

func _ready() -> void:
	get_tree().process_frame
	hp = hp_max
	health_changed.emit()
	get_tree().process_frame
	states_pool = states.duplicate()
	states_pool.shuffle()
	fill_tears_spawns()
	choose_modes()
	
func _process(delta: float) -> void:
	if float(hp) / float(hp_max) < 0.65:
		stage = 2
	if player:
		var to_player = (player.global_position - global_position)
		var dir = to_player.normalized()
		var offset = Vector2(
			clamp(dir.x * abs(to_player.x), -max_offset.x, max_offset.x),
			clamp(dir.y * abs(to_player.y), -max_offset.y, max_offset.y)
		)
		eyeball.position = eyeball_center + offset
		collision.position = eyeball.position
	else:
		eyeball.position = eyeball_center
		player = Game_Manager.player
	
	if sad and not tears_timer.time_left > 0:
		tears_timer.start()
	if turret and not turret_timer.time_left > 0:
		turret_timer.start()
	if angry and not angry_timer.time_left > 0:
		angry_timer.start()
	if iframes:
		collision.set_deferred("disabled", true)
	elif vulnerable:
		collision.set_deferred("disabled", false)
	else:
		collision.set_deferred("disabled", true)
		
func choose_modes():
	reset_states()

	if states_pool.size() < stage:
		states_pool = states.duplicate()
		states_pool.shuffle()

	if float(hp) / float(hp_max) < 0.4:
		sad = true
		vulnerable = true
	else:
		var chosen = states_pool.slice(0, stage)
		states_pool = states_pool.slice(stage, states_pool.size())

		for state_name in chosen:
			self.set(state_name, true)

	eyeball_sprite_chooser()

func eyeball_sprite_chooser():
	if float(hp) / float(hp_max) < 0.1:
		sad = true
	if stage == 1:
		if vulnerable:
			eyeball.texture = preload("res://assets/platformer/social_anxiety/floating_eye/vulnerable_eye.png")
		elif angry:
			eyeball.texture = preload("res://assets/platformer/social_anxiety/floating_eye/angry_eye.png")
		elif sad:
			eyeball.texture = preload("res://assets/platformer/social_anxiety/floating_eye/sad_eye.png")
		else:
			eyeball.texture = preload("res://assets/platformer/social_anxiety/floating_eye/turret_eye.png")
	else:
		# Build texture name from active states
		var active_states = []
		if vulnerable: active_states.append("v")
		if angry: active_states.append("a")
		if sad: active_states.append("s")
		if turret: active_states.append("t")

		active_states.sort()
		var joined_states = "_".join(active_states)
		var file_name = "res://assets/platformer/social_anxiety/floating_eye/%s.png" % [joined_states]
		eyeball.texture = load(file_name)
		
func reset_states():
	vulnerable = false
	angry = false
	sad = false
	turret = false

func attack_crying():
	if tear_spawn_pool.is_empty():
		tear_spawn_pool = tear_spawn_locations.duplicate()
	
	tear_spawn_pool.shuffle()
	var tear = tear_scene.instantiate()
	tear.global_position = tear_spawn_pool[0]
	tear.player = player
	get_tree().current_scene.add_child(tear)
	
	tear_spawn_pool.pop_front()

func fill_tears_spawns():
	var top_left = camera.get_screen_center_position() - (get_viewport_rect().size / camera.zoom) / 2
	var top_right = Vector2(top_left.x + get_viewport_rect().size.x / camera.zoom.x, top_left.y)
	
	var tear_count := 20
	var spacing = (top_right.x - top_left.x) / (tear_count - 1)
	
	for i in range(tear_count):
		var x = top_left.x + spacing * i
		var y = top_left.y  # stay at top edge
		tear_spawn_locations.append(Vector2(x, y))
	
	tear_spawn_pool = tear_spawn_locations.duplicate()

func _on_change_type_timeout() -> void:
	anim_tree["parameters/conditions/blink"] = true

func _on_time_between_tears_timeout() -> void:
	if not sad:
		tears_timer.stop()
		return
	else: attack_crying()

func _on_turret_shot_timeout() -> void:
	if not turret:
		turret_timer.stop()
		return
	var missile_count := 12
	var angle_step := TAU / missile_count  # TAU is 2 * PI, a full circle
	
	for i in missile_count:
		var angle = i * angle_step
		var direction = Vector2.RIGHT.rotated(angle)  # Start from right and rotate
		var missile = missile_scene.instantiate()
		missile.speed /= self.scale.x  # Assuming uniform scaling
		missile.scale /= self.scale
		missile.global_position = eyeball_center
		missile.velocity = direction * missile.speed
		missile.rotation = direction.angle()
		missile.player = player
		add_child(missile)

func _on_angry_shot_timeout() -> void:
	if not angry:
		angry_timer.stop()
		return
		
	if player:
		var to_player = (player.global_position - global_position).normalized()
		var missile = missile_scene.instantiate()
		missile.global_position = eyeball_center
		missile.speed = 250
		missile.velocity = to_player * missile.speed
		missile.rotation = to_player.angle()
		missile.player = player
		missile.scale /= self.scale
		add_child(missile)

func take_damage(incoming_damage):
	if vulnerable and not iframes:
		hp -= incoming_damage
		health_changed.emit()
		$Invulnerable.start()
		iframes = true
		collision.set_deferred("disabled", true)
		if not flashing:
			flashing = true
			flash_white()

func _on_invulnerable_timeout() -> void:
	iframes = false
	collision.set_deferred("disabled", false)

func flash_white():
	while iframes:
		eyeball.modulate = Color(0.451, 0.451, 0.451)
		await get_tree().create_timer(0.125).timeout
		eyeball.modulate = Color(1.0, 1.0, 1.0)
		await get_tree().create_timer(0.125).timeout
	flashing = false
