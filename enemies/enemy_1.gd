extends CharacterBody2D

@export var destroyed_image: Texture2D
@export var xp_reward: int = 25 

var health = 100
var is_destroyed = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func take_damage(amount: int):
	if is_destroyed:
		return 
		
	health -= amount
	
	if health <= 0:
		explode()

func explode():
	is_destroyed = true
	
	PlayerData.add_xp(xp_reward)
	
	if destroyed_image:
		sprite.texture = destroyed_image
		
	collision.set_deferred("disabled", true)
	remove_from_group("enemies")
	
	await get_tree().create_timer(3.0).timeout
	
	queue_free()
