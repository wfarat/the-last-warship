extends Node2D
class_name EnemyCannon

@export_group("Targeting & AI")
@export var target_group: String = "player" # "enemies" for player guns, "player" for enemy guns
@export var max_range: float = 600.0 # Don't target things beyond this pixel distance
@export var traverse_arc_degrees: float = 180.0

@export_group("Stats & Tiers")
@export var tier_fire_rates: Array[float] = [0.5, 0.35, 0.2] 
@export var tier_damage: Array[int] = [20, 30, 45]
@export var tier_price: Array[int] = [300, 600, 900]
var current_tier: int = 0

@export_group("Components")
@export var bullet_scene: PackedScene 

var fire_rate: float = 0.5 
var damage: int = 20
var current_cooldown: float = 0.0

# This stores the direction the cannon was originally placed in the editor!
var base_local_rotation: float 

@onready var muzzle = $Muzzle

func _ready() -> void:
	# Save the resting angle of the weapon so we know what "forward" is for this specific gun
	base_local_rotation = rotation

func _physics_process(delta: float) -> void:
	# 1. Handle Cooldown
	if current_cooldown > 0.0:
		current_cooldown -= delta
		
	# 2. Find the closest valid target
	var target = get_closest_target()
	
	if target:
		aim_at_target(target.global_position)
		
		# 3. Only shoot if cooldown is ready AND the gun is actually pointing at the target!
		if current_cooldown <= 0.0:
			shoot()
			current_cooldown = fire_rate

# --- TARGETING LOGIC ---

func get_closest_target() -> Node2D:
	var targets = get_tree().get_nodes_in_group(target_group)
	var closest_target: Node2D = null
	# We use infinity as the starting closest distance
	var closest_dist = INF 
	
	for t in targets:
		if "health" in t and t.health <= 0:
			continue # Target is out of HP, skip it!
		# distance_squared_to is much better for performance than standard distance_to
		var dist = global_position.distance_squared_to(t.global_position)
		
		# Check if it's the closest AND if it's within our max range!
		if dist < closest_dist and dist <= (max_range * max_range):
			closest_dist = dist
			closest_target = t
			
	return closest_target

# --- AIMING LOGIC ---

func aim_at_target(target_pos: Vector2) -> void:
	# Calculate where the gun WANTS to look
	var angle_to_target = global_position.direction_to(target_pos).angle()
	var desired_global_rotation = angle_to_target + (PI / 2.0)
	
	# Apply the rotation temporarily
	global_rotation = desired_global_rotation
	
	# THE CLAMP: Force the gun back inside its allowed turning arc
	var half_traverse = deg_to_rad(traverse_arc_degrees) / 2.0
	
	# Wrapf keeps the math from breaking when rotating past 360 degrees
	var angle_diff = wrapf(rotation - base_local_rotation, -PI, PI)
	
	# Clamp the difference so it can't turn further than the allowed arc
	var clamped_diff = clamp(angle_diff, -half_traverse, half_traverse)
	
	# Apply the locked rotation!
	rotation = base_local_rotation + clamped_diff



# --- SHOOTING & UPGRADES ---

func shoot():
	if not bullet_scene: return 
	var spawned_bullet = bullet_scene.instantiate()
	spawned_bullet.global_position = muzzle.global_position
	spawned_bullet.global_rotation = global_rotation
	spawned_bullet.damage = damage
	spawned_bullet.target_group = target_group
	get_tree().current_scene.add_child(spawned_bullet)
	play_shoot_effects()

func play_shoot_effects():
	pass
