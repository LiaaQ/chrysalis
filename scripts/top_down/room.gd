extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var companion_light: PointLight2D = $Assets/YSort/CompanionLight
@onready var closet: Interactable = $Assets/YSort/Closet

@export var mirror: Mirror

var finished_interactions = {}
var curr_interaction: String
var companion: Node2D = null

func _ready() -> void:
	Game_Manager.movement_locked = true
	Dialogic.timeline_ended.connect(interaction_ended)
	Dialogic.timeline_started.connect(interaction_started)
	Dialogic.signal_event.connect(interaction_event)
	var song = Game_Manager.get_node("Level1/Sounds/Topdown_Depressing")
	song.play()

func _process(delta: float) -> void:
	if finished_interactions.size() > 3 and companion == null:
		companion_light.visible = true
		closet.dialogic_timeline = "closet2"

func light():
	canvas_modulate.visible = false
	mirror.light()
	
func dark():
	canvas_modulate.visible = true
	mirror.dark()

func interaction_ended():
	if curr_interaction:
		finished_interactions.get_or_add(curr_interaction)

func interaction_started():
	curr_interaction = Dialogic.current_timeline._to_string()

func interaction_event(arg: String):
	if arg == "companion":
		companion = preload("res://scenes/Top_Down/companion.tscn").instantiate()
		companion.global_position = Vector2(Game_Manager.player.global_position + companion.offset)
		companion.z_index = 1
		companion.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
		companion.dialogic_timeline = "depression_platformer_start"
		get_node("Assets/YSort").add_child(companion)
		companion_light.queue_free()
		closet.dialogic_timeline = "closet3"
	if arg == "platformer_start":
		Game_Manager.curr_checkpoint = "Depression_Platformer"
		await Game_Manager.change_scene_fade_out("res://scenes/Platformer/Depression/platformer_depression.tscn")
