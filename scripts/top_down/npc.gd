extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var spritesheet: Texture2D
@export var init_move: String
@export var direction: Vector2i = Vector2(0, 1)

var frame_size: Vector2i = Vector2i(32, 64)

func _ready():
	if spritesheet:
		var sprite_frames = SpriteFrames.new()
		setup_animations(sprite_frames, "idle", 1)
		setup_animations(sprite_frames, "run", 2)
		sprite.sprite_frames = sprite_frames

	sprite.play(init_move + "_" + get_direction_name(direction))

func setup_animations(sprite_frames: SpriteFrames, move_name: String, row: int):
	var directions = {
		"right": 0,
		"back": 1,
		"left": 2,
		"front": 3,
	}

	for dir_name in directions:
		var dir_index = directions[dir_name]
		var anim_name = move_name + "_" + dir_name
		sprite_frames.add_animation(anim_name)
		sprite_frames.set_animation_speed(anim_name, 5)

		for i in range(6):  # 6 frames per direction
			var col = dir_index * 6 + i
			var region = Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)

			var atlas = AtlasTexture.new()
			atlas.atlas = spritesheet
			atlas.region = region

			sprite_frames.add_frame(anim_name, atlas)

	
func get_direction_name(vec: Vector2i) -> String:
	if vec == Vector2i(0, 1):
		return "front"
	elif vec == Vector2i(1, 0):
		return "right"
	elif vec == Vector2i(0, -1):
		return "back"
	elif vec == Vector2i(-1, 0):
		return "left"
	return "unknown"
