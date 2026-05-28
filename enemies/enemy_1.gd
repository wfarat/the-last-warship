extends CharacterBody2D

@export var destroyed_image: Texture2D

var health = 100
var is_destroyed = false # Prevents the wreckage from taking more damage

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func take_damage(amount: int):
	# If the ship is already destroyed, ignore any extra hits
	if is_destroyed:
		return 
		
	health -= amount
	
	# Check if the health has dropped to 0 or below
	if health <= 0:
		explode()

func explode():
	is_destroyed = true # Mark as dead
	
	# Swap the texture to the wrecked ship
	if destroyed_image:
		sprite.texture = destroyed_image
		
	# Turn off collision and remove from the target group
	collision.set_deferred("disabled", true)
	remove_from_group("enemies")
