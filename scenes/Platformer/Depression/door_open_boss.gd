extends Interactable

var entered: bool = false

func _ready() -> void:
	super()
	
func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interact") and visible:
		interact()

func interact():
	super()
	Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
	await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/Phase1/room_after.tscn")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		entered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Game_Manager.player:
		entered = false
