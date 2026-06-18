extends Area2D

const MAX_SPEED = 600.0
const MAX_RANGE = 800.0 

var current_speed = MAX_SPEED
var distance_traveled: float = 0.0 
var damage: int = 20

@onready var sprite = $AnimatedSprite2D
var target_group: String = ""

func _ready() -> void:
	sprite.play("flying")
	# 1. Wipe the default editor settings clean
	collision_layer = 0
	collision_mask = 0
	
	# 2. Always look for the Environment (Layer 5) so it hits islands
	set_collision_mask_value(5, true)
	
	# 3. Configure based on the target group assigned by the weapon
	if target_group == "enemies":
		# The PLAYER fired this bullet
		set_collision_layer_value(3, true) # I am a Player Bullet
		set_collision_mask_value(2, true)  # I look for Enemies
		
	elif target_group == "player":
		# An ENEMY fired this bullet
		set_collision_layer_value(4, true) # I am an Enemy Bullet
		set_collision_mask_value(1, true)  # I look for the Player

func _physics_process(delta: float) -> void:
	var move_amount = current_speed * delta
	var forward_vector = Vector2.UP.rotated(rotation)
	position += forward_vector * move_amount
	distance_traveled += move_amount
	
	if distance_traveled >= MAX_RANGE:
		detonate()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			
		detonate()

func detonate():
	set_physics_process(false)
	current_speed = 0.0
	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
