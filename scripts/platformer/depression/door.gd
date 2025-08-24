extends Interactable

var entered: bool = false

func _ready() -> void:
	super()
	Dialogic.signal_event.connect(dialogic_signal)
	
func _process(delta: float) -> void:
	if entered and Input.is_action_just_pressed("interact"):
		interact()

func interact():
	super()
	if not Game_Manager.interaction_locked:
		Dialogic.start(dialogic_timeline)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		entered = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == Game_Manager.player:
		entered = false

func dialogic_signal(arg: String):
	if arg == "start":
		await Game_Manager.change_scene_fade_out("res://scenes/Platformer/Depression/platformer_depression_bossfight.tscn")
