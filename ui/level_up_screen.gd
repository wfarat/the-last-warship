extends CanvasLayer

@onready var options_container = $Panel/OptionsContainer

func _ready() -> void:
	hide()
	
	PlayerData.leveled_up.connect(_on_player_leveled_up)

func _on_player_leveled_up(_new_level: int) -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		trigger_level_up(player)

func trigger_level_up(player: Node2D) -> void:
	var skill_manager = player.get_node_or_null("SkillManager")
	if not skill_manager: return
		
	for child in options_container.get_children():
		child.queue_free()
	GameManager.change_state(GameManager.GameState.UPGRADE)
	get_tree().paused = true
	show()
	
	var skills = skill_manager.get_children()
	for skill in skills:
		if skill.current_level < skill.max_level:
			var btn = Button.new()
			btn.text = "Ulepsz " + skill.name + "\n(Lvl " + str(skill.current_level + 1) + ")"
			btn.custom_minimum_size = Vector2(200, 300)
			
			if skill.icon:
				btn.icon = skill.icon
				btn.expand_icon = true
				
				btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
				btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
			
			btn.pressed.connect(_on_upgrade_chosen.bind(skill))
			options_container.add_child(btn)

func _on_upgrade_chosen(skill_to_upgrade: Skill) -> void:
	skill_to_upgrade.upgrade()
	GameManager.change_state(GameManager.GameState.PLAYING)
	get_tree().paused = false
	hide()
