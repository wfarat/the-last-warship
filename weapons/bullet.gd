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
	
	set_collision_mask_value(5, true)
	
	if target_group == "enemies":
		set_collision_layer_value(3, true)
		set_collision_mask_value(2, true)
		
	elif target_group == "player":
		set_collision_layer_value(4, true) 
		set_collision_mask_value(1, true)

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
	else:
		queue_free()

func detonate():
	set_physics_process(false)
	current_speed = 0.0
	sprite.play("explode")
	await sprite.animation_finished
	queue_free()
