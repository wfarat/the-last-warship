extends AnimatedSprite2D
# Arrays to hold the data for each tier!
# Index 0 is Tier 1, Index 1 is Tier 2, etc.
@export var tier_animations: Array[SpriteFrames] 
@export var tier_fire_rates: Array[float] = [0.5, 0.35, 0.2] 
@export var tier_damage: Array[int] = [20, 30, 45]
@export var tier_price: Array[int] = [300, 600, 900]
var current_tier: int = 0 # Starts at 0 (Tier 1)
@export var bullet_scene: PackedScene 
@export var fire_rate: float = 0.5 
@export var damage: int = 20

var current_cooldown: float = 0.0

# Since the script is on the Cannon, Muzzle is just a direct child
@onready var muzzle = $Muzzle

func _physics_process(delta: float) -> void:
	var angle_to_mouse = global_position.direction_to(get_global_mouse_position()).angle()
	global_rotation = angle_to_mouse + (PI / 2.0)

	if current_cooldown > 0.0:
		current_cooldown -= delta
		
	if current_cooldown <= 0.0:
		shoot()
		current_cooldown = fire_rate

func shoot():
	if not bullet_scene:
		return 
		
	var spawned_bullet = bullet_scene.instantiate()
	spawned_bullet.global_position = muzzle.global_position
	spawned_bullet.global_rotation = global_rotation
	spawned_bullet.damage = damage
	get_tree().current_scene.add_child(spawned_bullet)
	
	play("shoot")
	await animation_finished
	play("idle")
func upgrade_tier():
	# Check if we haven't reached the max level yet
	if current_tier < tier_animations.size() - 1:
		current_tier += 1
		
		# 1. Swap the visual animations!
		sprite_frames = tier_animations[current_tier]
		fire_rate = tier_fire_rates[current_tier]
		
func next_tier_price():
	if current_tier < tier_animations.size() - 1:
		return tier_price[current_tier+1]
	else:
		return 0
