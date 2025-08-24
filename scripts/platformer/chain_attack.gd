extends Area2D

@export var speed: float = 1000.0
@export var max_length: float = 1500.0
@export var possible_keys: Array[String]

var hbox: HBoxContainer
var direction: Vector2
var current_length: float = 0.0
var is_extending := true
var amount_of_keys: int = 4
var chain_sequence: Array[String] = []

@onready var timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sound: AudioStreamPlayer2D = $Sound

func _ready():
	hbox = get_tree().current_scene.player.get_node("Camera2D/Control/HBoxContainer")
	
	current_length = 0.0
	is_extending = true
	var shape = collision.shape
	if shape:
		collision.shape = shape.duplicate()
	sound.play()

func _process(delta):
	if is_extending:
		var stretch = speed * delta
		current_length += stretch
		if current_length >= max_length:
			sound.stop()
			queue_free()
		update_chain()

func update_chain():
	# Update sprite region size (chain's visual length)
	sprite.region_rect.size.x = current_length
	sprite.position.x = current_length / 2
	# Update collision size
	var rect_shape := collision.shape as RectangleShape2D
	if rect_shape:
		rect_shape.extents.x = current_length / 2
		collision.position.x = current_length / 2

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("get_chained"):
		print("Player chained")
		show_puzzle()
		body.get_chained(chain_sequence)
		free_chain()

func free_chain():
	is_extending = false
	sprite.queue_free()
	sound.stop()
	collision.queue_free()

func show_puzzle():
	for child in hbox.get_children():
		child.queue_free()
	chain_sequence.clear()
	
	for i in range(amount_of_keys):
		var key = possible_keys[randi() % possible_keys.size()]
		chain_sequence.append(key)
		
		var tex_rect = TextureRect.new()
		tex_rect.texture = preload("res://assets/platformer/depression/key.png")
		
		var label = Label.new()
		label.text = key.to_upper()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.size = Vector2(40.0, 40.0)
		
		tex_rect.add_child(label)
		hbox.add_child(tex_rect)
