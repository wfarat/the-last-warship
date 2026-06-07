extends Skill
class_name HealSkill

@export var heal_amount: int = 5000
@export var heal_effect_scene: PackedScene

func activate_effect(caster: Node2D) -> void:
	if caster.has_method("heal"):
		
		caster.heal(heal_amount)
		if heal_effect_scene:
			var fx = heal_effect_scene.instantiate()
			
			# KRYTYCZNE: Dodajemy efekt jako DZIECKO statku (caster), 
			# dzięki temu animacja będzie pływać razem ze statkiem!
			caster.add_child(fx)
			
			# Ustawiamy pozycję na (0,0) względem statku, żeby animacja była idealnie na środku
			fx.position = Vector2.ZERO
func apply_upgrade_stats() -> void:
	heal_amount += 1000
	
	base_cooldown = max(3.0, base_cooldown - 1.0)
