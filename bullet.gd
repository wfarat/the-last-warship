extends Area2D

const MAX_SPEED = 600.0
const MAX_RANGE = 800.0 
const DAMAGE = 20 # How much damage one rocket deals

var current_speed = MAX_SPEED
var distance_traveled: float = 0.0 

@onready var sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var move_amount = current_speed * delta
	var forward_vector = Vector2.UP.rotated(rotation)
	position += forward_vector * move_amount
	distance_traveled += move_amount
	
	if distance_traveled >= MAX_RANGE:
		detonate()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		# Check if the enemy has our damage function, then pass the damage amount
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE)
			
		detonate() # Blow up the rocket

func detonate():
	current_speed = 0.0
	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
