extends Skill
class_name RocketSkill

@export var magic_scene: PackedScene 
@export var damage: int = 100

@export var magic_range: float = 400.0 # Define a maximum range for the controller aim

func activate_effect(caster: Node2D, controller: bool) -> void:
	if not magic_scene: return
		
	var magic = magic_scene.instantiate()
	magic.damage = damage

	# --- NEW: CHOOSE AIMING METHOD BASED ON CONTROLLER PARAMETER ---
	var target_pos: Vector2
	
	if controller:
		# 1. Get the 2D vector from the Right Analog Stick
		var aim_vector = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		# Check if the player is actually tilting the stick (ignoring minor drift)
		if aim_vector.length() > 0.1:
			# Aim in the direction the stick is pointed, extended to maximum range
			target_pos = caster.global_position + (aim_vector.normalized() * magic_range)
		else:
			# Fallback: If they aren't touching the stick, shoot directly ahead of the ship!
			var forward_vector = Vector2.UP.rotated(caster.rotation)
			target_pos = caster.global_position + (forward_vector * magic_range)
	else:
		# 2. Mouse Aiming Fallback
		target_pos = caster.get_global_mouse_position()
		
	# Assign the final resolved position to the magic projectile
	magic.target_position = target_pos
	
	# ---------------------------------------------------------------
	
	caster.get_tree().current_scene.add_child(magic)
	
	# 3. SET POSITIONING AFTER ADDING TO TREE
	magic.global_position = caster.global_position
	magic.global_rotation = caster.global_position.direction_to(magic.target_position).angle() + PI
func apply_upgrade_stats() -> void:
	damage += 30
	base_cooldown -= 0.5
