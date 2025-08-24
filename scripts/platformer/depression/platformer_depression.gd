extends Node2D

@export var skeleton: CharacterBody2D
@export var camera: Camera2D
@export var player_portrait: Sprite2D
var player: CharacterBody2D
var amount_powerups: int = 0

@onready var door_sprite: Sprite2D = $Tiles/Door/Sprite
@onready var door: Interactable = $Tiles/Door

func _ready() -> void:
	Dialogic.signal_event.connect(dialogic_signal)
	Dialogic.start("Depression/depression_platformer_start")
	var song = Game_Manager.get_node("Level1/Sounds/Topdown_Depressing")
	song.stop()

func dialogic_signal(arg: String):
	if arg == "transform":
		skeleton.dead = true
		var root = get_tree().current_scene
		root.add_child(camera)
		
		player = preload("res://scenes/Platformer/Depression/player_depression_platformer.tscn").instantiate()
		player.global_position = skeleton.global_position
		player.damage = 10
		player.z_index = 1
		root.add_child(player)
		player.sprite.material.set_shader_parameter("saturation_level", 0.0)
		
		var player_hp = camera.get_node("PlayerHP")
		player_hp.player = player
		player_hp.load()
		player_portrait.texture = preload("res://assets/platformer/depression/Knight_player/portrait.png")
		camera.reparent(player)

func player_power_up():
	amount_powerups+=1
	if amount_powerups == 1:
		Dialogic.start("first_powerup")
	player.damage += 1
	var curr_sat = player.sprite.material.get_shader_parameter("saturation_level")
	print(curr_sat+0.1)
	if curr_sat+0.1 >= 0.95:
		Dialogic.start("full_power")
		door_sprite.texture = preload("res://assets/platformer/depression/tileset/door_open.png")
		door.dialogic_timeline = "door_open"
		
	player.sprite.material.set_shader_parameter("saturation_level", min(curr_sat+0.1, 1.0))
