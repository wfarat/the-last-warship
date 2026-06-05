extends Area2D

@export var speed: float = 400.0

var damage: int = 50
var is_exploding: bool = false

var target_position: Vector2 

@onready var anim = $AnimatedSprite2D
@onready var blast_shape = $BlastRadius

func _ready() -> void:
	anim.play("flying")

func _physics_process(delta: float) -> void:
	if not is_exploding:
		
		var step = speed * delta
		global_position = global_position.move_toward(target_position, step)
		
		if global_position == target_position:
			explode()

func explode() -> void:
	# Phase 2: EXPLODING
	is_exploding = true
	anim.play("explode")
	
	blast_shape.set_deferred("disabled", false)
	
	await get_tree().physics_frame
	
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("enemies"):
			# Zombie filter! Only hurt enemies with health
			if "health" in body and body.health > 0:
				if body.has_method("take_damage"):
					body.take_damage(damage)
	
	# Wait for the explosion animation to finish playing, then delete the rocket
	await anim.animation_finished
	queue_free()
