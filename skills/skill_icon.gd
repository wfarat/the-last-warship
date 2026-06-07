extends TextureProgressBar

# Keep track of what skill is currently sitting in this slot
var current_skill: Skill = null

func assign_skill(new_skill: Skill) -> void:
	# 1. CLEANUP: If we already had a skill here, disconnect it first!
	if current_skill != null:
		# .is_connected() prevents errors if it somehow wasn't connected
		if current_skill.cooldown_updated.is_connected(_on_cooldown_updated):
			current_skill.cooldown_updated.disconnect(_on_cooldown_updated)
			
	# 2. ASSIGN THE NEW SKILL
	current_skill = new_skill
	
	# 3. SET VISUALS
	if current_skill.icon:
		texture_under = current_skill.icon
		
	# 4. CONNECT NEW SIGNALS
	current_skill.cooldown_updated.connect(_on_cooldown_updated)
	
	# Reset the UI bar just in case
	value = 0
	max_value = current_skill.base_cooldown

func _on_cooldown_updated(time_left: float, max_time: float) -> void:
	max_value = max_time
	value = time_left
