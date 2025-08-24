extends Node2D

@onready var eyeball_ui: Sprite2D = $Camera2D/Node2D/Eyeball
@onready var eyeboss: Area2D = $Eye_Boss
@onready var real_char: Interactable = $Interactable

var fading_out: bool = false

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)

func _process(delta: float) -> void:
	if fading_out:
		$ColorRect.modulate.a -= delta
	if $ColorRect.modulate.a <= 0:
		real_char.get_node("Area2D/CollisionShape2D").set_deferred("disabled", false)
	if eyeboss:
		eyeball_ui.texture = eyeboss.eyeball.texture
		if float(eyeboss.hp) / float(eyeboss.hp_max) < 0.1:
			$ColorRect.global_position.y -= delta * 80
			if $ColorRect.global_position.y <= -48.0:
				fading_out = true
				real_char.visible = true
				$Song.stop()
				$Crowd.volume_db = 0
				eyeboss.queue_free()

func _dialogic_signal(arg):
	if arg == "leave_level":
		Game_Manager.curr_checkpoint = "Social_After"
		Game_Manager.spawn_position = Game_Manager.UNUSED_VECTOR
		await Game_Manager.change_scene_fade_out("res://scenes/Top_Down/outside_after_social.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		real_char.get_node("AnimatedSprite2D").flip_h = (Game_Manager.player.global_position.x < real_char.global_position.x)
		Dialogic.start("social_platformer_finish")
