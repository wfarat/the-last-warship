extends TextureProgressBar

# Keep track of what skill is currently sitting in this slot
var current_skill: Skill = null
@onready var level_label = $LevelLabel
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
	_update_level_text(current_skill.current_level)
	
	if not current_skill.skill_upgraded.is_connected(_update_level_text):
		current_skill.skill_upgraded.connect(_update_level_text)
func _on_cooldown_updated(time_left: float, max_time: float) -> void:
	max_value = max_time
	value = time_left

func _update_level_text(new_level: int) -> void:
	if new_level >= current_skill.max_level:
		level_label.text = "MAX"
		level_label.add_theme_color_override("font_color", Color.GOLD) # Opcjonalnie: Złoty kolor dla wymaksowanego skilla!
	else:
		level_label.text = "Lvl " + str(new_level)
