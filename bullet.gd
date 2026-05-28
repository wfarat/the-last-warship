extends Area2D

const MAX_SPEED = 600.0
const MAX_RANGE = 800.0 

var current_speed = MAX_SPEED
var distance_traveled: float = 0.0 
var damage: int = 20

@onready var sprite = $AnimatedSprite2D

# 1. _ready() runs exactly ONCE the moment the rocket is created
func _ready() -> void:
	sprite.play("flying")

func _physics_process(delta: float) -> void:
	# 2. We removed the play("flying") command from this 60fps loop!
	var move_amount = current_speed * delta
	var forward_vector = Vector2.UP.rotated(rotation)
	position += forward_vector * move_amount
	distance_traveled += move_amount
	
	if distance_traveled >= MAX_RANGE:
		detonate()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
		detonate()

func detonate():
	# 3. This built-in function completely shuts off _physics_process
	# so the rocket stops thinking, moving, and checking distances
	set_physics_process(false)
	
	current_speed = 0.0
	sprite.play("explode")
	
	await sprite.animation_finished
	queue_free()
