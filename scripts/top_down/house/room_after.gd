extends Node2D

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var companion_light: PointLight2D = $Assets/YSort/CompanionLight
@onready var closet: Interactable = $Assets/YSort/Closet

@export var mirror: Mirror
@export var companion: Interactable

var finished_interactions = {}
var curr_interaction: String
var manager_array = "room_fixed_items"

func _ready() -> void:
	var array = Game_Manager.room_fixed_items
	for item in array:
		var object = get_node_or_null(item)
		if object and object.has_method("interact"):
			object.interact()
	companion.fade_out()
	if array.is_empty():
		Dialogic.start("room_after_depression_bossfight")
	Dialogic.timeline_ended.connect(interaction_ended)
	Dialogic.timeline_started.connect(interaction_started)
	var song = Game_Manager.get_node("Level1/Sounds/Topdown_Happy")
	if not song.playing:
		song.play()
		Game_Manager.curr_song = song

func _process(delta: float) -> void:
	if finished_interactions.size() > 5 and companion == null:
		companion_light.visible = true
		closet.dialogic_timeline = "closet2"

func light():
	canvas_modulate.visible = false
	if mirror:
		mirror.light()
	
func dark():
	canvas_modulate.visible = true
	if mirror:
		mirror.dark()

func interaction_ended():
	if curr_interaction:
		finished_interactions.get_or_add(curr_interaction)

func interaction_started():
	curr_interaction = Dialogic.current_timeline._to_string()
