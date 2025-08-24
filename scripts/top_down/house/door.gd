extends Area2D

@export var scene: String
@export var new_position: Vector2

var fallback_scene_path: String

func _process(delta: float) -> void:
	print(Game_Manager.interaction_locked)
	if Game_Manager.player:
		if Game_Manager.player.raycast.is_colliding() and Game_Manager.player.raycast.get_collider() == self:
			if Input.is_action_just_pressed("interact") and not Game_Manager.interaction_locked and Dialogic.current_timeline == null:
				print("Interacting")
				interact()

func interact():
	Game_Manager.interaction_locked = true
	if new_position:
		Game_Manager.spawn_position = new_position
	else: Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
	if scene:
		await Game_Manager.change_scene_fade_out(scene)
