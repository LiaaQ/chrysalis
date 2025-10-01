extends StaticBody2D
class_name UnalignedBlock

@onready var area: Area2D = $Area2D
@onready var timer_offset: Timer = $offset
@onready var timer_cooldown: Timer = $cooldown
@onready var sprite: Sprite2D = $Sprite2D
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var is_visible: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var label: Label = $Label
@onready var ascend_sound: AudioStreamPlayer2D = $ascend
@onready var descend_sound: AudioStreamPlayer2D = $descend

@export var offset_time: float = 1.5
@export var offset: float = 20.0
@export var cooldown: float = 8.0
@export var texture: Texture2D:
	set(value):
		texture = value
		if sprite:
			sprite.texture = value
@export var platformer_version: bool = true

var original_pos: float
var offset_pos: float
var moving: bool = false
var aligned: bool = true
var counter: int = 0

func _ready() -> void:
	sprite.texture = texture
	original_pos = global_position.y
	if platformer_version:
		offset_pos = original_pos + offset
		timer_offset.wait_time = offset_time
		timer_cooldown.wait_time = cooldown

func _process(delta: float) -> void:
	if moving:
		var target_y := offset_pos if aligned else original_pos
		var distance := target_y - global_position.y
		var move_amount = delta * 100 * sign(distance)
		
		if abs(distance) <= 2:
			global_position.y = target_y
			moving = false
			aligned = not aligned
			if aligned:
				label.text = ""
		else:
			global_position.y += move_amount

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player and not aligned and global_position.y != original_pos:
		counter += 1
		label.text = "%d!" % counter

		if counter == 3:
			counter = 0
			moving = true
			if not Game_Manager.first_block_fixed:
				Dialogic.start("OCD_first_block_fixed")
				Game_Manager.first_block_fixed = true
			if platformer_version:
				timer_cooldown.start()
			else:
				get_tree().current_scene.unaligned_blocks.append(self)
				get_tree().current_scene.anxiety_gain += get_tree().current_scene.ANXIETY_BOX_SUCCESS
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if aligned and platformer_version:
		timer_offset.start()

func unalign(incoming_offset: float) -> void:
	
	offset = incoming_offset
	offset_pos = original_pos + offset
	aligned = true

	$Area2D/top.disabled = offset >= 0
	$Area2D/bottom.disabled = offset < 0

	moving = true

func _on_offset_timeout() -> void:
	moving = true

func _on_cooldown_timeout() -> void:
	moving = true
