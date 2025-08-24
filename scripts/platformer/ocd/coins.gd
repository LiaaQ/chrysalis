extends Node2D

var amount: int
var next_coin: int = 1
var coins: Array[Area2D]
@export var areas: Array[CollisionShape2D]
@export var platformer_version: bool = false

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			areas.append(child)
	amount = areas.size()
	spawn_coins()
	areas.clear()
	
func _process(delta: float) -> void:
	pass

func spawn_coins():
	areas.shuffle()
	for i in range(amount):
		var coin = preload("res://scenes/Platformer/OCD/coin.tscn").instantiate()
		add_child(coin)
		coin.global_position = areas[i].global_position
		coin.label.text = str(i+1)
		coin.connect("body_entered", Callable(self, "_on_coin_body_entered").bind(coin))
		coins.append(coin)

func _on_coin_body_entered(body, coin):
	if body == Game_Manager.player:
		print("Coin touched:", int(coin.label.text))
		if int(coin.label.text) == next_coin:
			coins.erase(coin)
			coin.queue_free()
			next_coin += 1
			if next_coin > amount and not platformer_version:
				if not Game_Manager.first_coin_fixed:
					Dialogic.start("OCD_first_coin_fixed")
					Game_Manager.first_coin_fixed = true
				get_tree().current_scene.anxiety_gain += get_tree().current_scene.ANXIETY_DECREASE_COIN_SUCCESS
				coins = []
				get_tree().current_scene.coins_timer.start()
				
		else:
			for curr_coin in coins:
				Dialogic.VAR.set_variable("coin", int(coin.label.text))
				Dialogic.VAR.set_variable("wanted_coin", int(coin.label.text)-1)
				if not Game_Manager.first_coin_failed:
					Dialogic.start("OCD_first_coin_failed")
					Game_Manager.first_coin_failed = true
				curr_coin.modulate = Color.RED
				curr_coin.disconnect("body_entered", Callable(self, "_on_coin_body_entered").bind(curr_coin))
			if not platformer_version:
				get_tree().current_scene.update_anxiety(get_tree().current_scene.ANXIETY_INCREASE_COIN_FAIL)
				await get_tree().create_timer(4.0).timeout
				get_tree().current_scene.coins_timer.start()
				queue_free()
