extends Node2D
class_name BossWeapon

@export_group("Targeting & AI")
@export var target_group: String = "player" # "enemies" for player guns, "player" for enemy guns
@export var max_range: float = 800.0 # Don't target things beyond this pixel distance
@export var traverse_arc_degrees: float = 270.0
@export var turret_turn_speed: float = 3.0 # Lower means heavier, slower cannons!


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
		aim_at_target(target.global_position, delta)
		
		# 3. Only shoot if cooldown is ready AND the gun is actually pointing at the target!
		if current_cooldown <= 0.0 and is_aimed_at(target.global_position):
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

func aim_at_target(target_pos: Vector2, delta: float) -> void:
	# 1. Save where the cannon is currently pointing before we calculate the new angle
	var actual_current_rotation = rotation
	
	# 2. Find the perfect global angle to the player
	var angle_to_target = global_position.direction_to(target_pos).angle()
	var desired_global_rotation = angle_to_target + (PI / 2.0)
	
	# 3. Temporarily apply this perfect rotation. 
	# This is a trick so Godot automatically handles all the complex parent/child math!
	global_rotation = desired_global_rotation
	
	# 4. With the gun perfectly aimed, calculate how far it is twisted from its "Home"
	var half_traverse = deg_to_rad(traverse_arc_degrees) / 2.0
	var desired_twist = wrapf(rotation - base_local_rotation, -PI, PI)
	
	# 5. Clamp that twist so it cannot aim at the bridge
	var clamped_desired_twist = clamp(desired_twist, -half_traverse, half_traverse)
	
	# 6. REVERT the gun back to its actual physical rotation
	rotation = actual_current_rotation
	
	# 7. Calculate where the twist is right now
	var current_twist = wrapf(rotation - base_local_rotation, -PI, PI)
	
	# 8. THE MAGIC FIX: Smoothly move the current twist toward the goal twist.
	# Because move_toward is linear, if it wants to go from +135 to -135, 
	# it is forced to count all the way down through 0, sweeping around the front!
	var new_twist = move_toward(current_twist, clamped_desired_twist, turret_turn_speed * delta)
	
	# 9. Apply the final animated rotation
	rotation = base_local_rotation + new_twist

func is_aimed_at(target_pos: Vector2) -> bool:
	# Checks if the target is physically inside our allowed firing arc
	var angle_to_target = global_position.direction_to(target_pos).angle() + (PI / 2.0)
	var current_angle = global_rotation
	
	# If the difference between where we want to look and where we are looking is very small
	# (less than ~5 degrees), it means we successfully aimed at it.
	return abs(wrapf(angle_to_target - current_angle, -PI, PI)) < 0.1

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
