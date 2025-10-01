extends Node2D
class_name Mirror

@export var character: Node
@onready var mask: PointLight2D = $Mask

func _process(_delta):
	if not character:
		$Reflection.visible = false
		return
	else: $Reflection.visible = true

	var distance_y = character.global_position.y - global_position.y
	
	$Reflection.global_position = Vector2(
		character.global_position.x,
		global_position.y - distance_y + 55
	)

	update_reflection()

func update_reflection():
	var char_sprite = character.sprite
	var refl_sprite = $Reflection
	
	var anim_char = char_sprite.animation
	var anim_refl = anim_char
	
	if anim_char.ends_with("front"):
		anim_refl = anim_char.replace("front", "back")
	elif anim_char.ends_with("back"):
		anim_refl = anim_char.replace("back", "front")
		
	if refl_sprite.animation != anim_refl:
		refl_sprite.play(anim_refl)
	
	refl_sprite.frame = char_sprite.frame
	
func dark():
	mask.color = Color(0.23, 0.23, 0.23, 1.00)

func light():
	mask.color = Color(1.00, 1.00, 1.00, 1.00)
