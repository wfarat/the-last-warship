extends TextureProgressBar

# We will pass the skill to this function from the main HUD script
func assign_skill(skill_node: Skill) -> void:
	
	if skill_node.icon:
		texture_under = skill_node.icon
	skill_node.cooldown_updated.connect(_on_cooldown_updated)
	
func _on_cooldown_updated(time_left: float, max_time: float) -> void:
	max_value = max_time
	value = time_left
