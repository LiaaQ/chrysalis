extends CharacterBody2D

@onready var raycast_down: RayCast2D = $Ledge_Raycast
@onready var raycast_wall: RayCast2D = $Wall_Raycast
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var acceleration: float = 300
@export var speed: int = 100

var direction: Vector2 = Vector2(-1.0, 0.0)
var new_dir: float
var dead: bool = false

func _process(delta: float) -> void:
	if not dead:
		if !is_on_floor():
			velocity += get_gravity() * delta
		velocity = velocity.move_toward(direction * speed, acceleration * delta)
		check_turn()
		move_and_slide()
	else:
		$Idle_Timer.stop()

func check_turn():
	if not raycast_down.is_colliding() and not direction.x == 0.0:
		new_dir = -direction.x
		direction.x = 0.0
		$Idle_Timer.start()
		sprite.play("Idle")
	elif raycast_wall.is_colliding():
		turn(-direction.x)
		
func turn(new_dir: int):
	direction.x = new_dir
	sprite.scale.x *= -1
	raycast_down.position.x *= -1
	raycast_wall.scale.x *= -1

func _on_idle_timer_timeout() -> void:
	turn(new_dir)
	sprite.play("Walk")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == Game_Manager.player:
		sprite.play("Death")
		dead = true
		Game_Manager.killed_spiders += 1
		$Area2D/StompArea.queue_free()
		$CollisionShape2D.queue_free()
