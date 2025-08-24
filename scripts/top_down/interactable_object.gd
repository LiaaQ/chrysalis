extends StaticBody2D
class_name Interactable

@export var dialogic_timeline: String
@export var instant_trigger: bool = false

var target_sprite: Node = null
var sounds: Array[AudioStreamPlayer2D] = []
var sound_idx: int = 0

func _ready():
	set_collision_layer_value(7, true)
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			target_sprite = child
		elif child is AudioStreamPlayer2D:
			sounds.append(child)
		elif child is Area2D:
			child.set_collision_layer_value(7, true)

func interact():
	if dialogic_timeline != "":
		Dialogic.start(dialogic_timeline)
	if sounds.size() > 0:
		var curr_sound = sounds[sound_idx]
		curr_sound.play()
		sound_idx = (sound_idx + 1) % sounds.size()
