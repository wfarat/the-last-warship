extends Skill
class_name RocketSkill

@export var magic_scene: PackedScene 
@export var damage: int = 100

func activate_effect(caster: Node2D) -> void:
	if not magic_scene: return
		
	var magic = magic_scene.instantiate()
	magic.damage = damage
# 1. Grab the target position before doing anything else
	magic.target_position = caster.get_global_mouse_position()
	
	caster.get_tree().current_scene.add_child(magic)
	
	# 3. SET POSITIONING AFTER ADDING TO TREE
	magic.global_position = caster.global_position
	magic.global_rotation = caster.global_position.direction_to(magic.target_position).angle() + PI

func apply_upgrade_stats() -> void:
	damage += 30
	base_cooldown -= 0.5
