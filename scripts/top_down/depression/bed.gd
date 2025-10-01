extends Interactable

func _ready() -> void:
	super()
	
func interact():
	super()
	
func _process(delta: float) -> void:
	if $CharacterInBed.visible:
		if Input.is_action_just_pressed("interact"):
			$CharacterInBed.visible = false
			Game_Manager.player.visible = true
			Game_Manager.movement_locked = false
			if "mirror" in get_tree().current_scene:
				get_tree().current_scene.mirror.character = Game_Manager.player
			var label = get_tree().current_scene.get_node("CanvasLayer")
			if label:
				label.queue_free()
			Dialogic.start("out_of_bed")
