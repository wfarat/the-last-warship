extends CanvasLayer

@onready var gold_label = $MarginContainer/VBoxContainer/GoldLabel
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var xp_bar = $MarginContainer/VBoxContainer/XPBar
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar
@onready var icon_container = $SkillBar/HBoxContainer
@export var player_ship: CharacterBody2D 

func _ready() -> void:
	# Connect to the Global Vault
	PlayerData.gold_changed.connect(_update_gold_display)
	PlayerData.xp_changed.connect(_update_xp_display)
	PlayerData.leveled_up.connect(_update_level_display)
	
	# Connect to the Player
	if player_ship:
		player_ship.hp_changed.connect(_update_hp_display)
	
	# Force the UI to initialize right now
	_update_gold_display(PlayerData.gold)
	_update_level_display(PlayerData.level)
	_update_xp_display(PlayerData.xp, PlayerData.xp_to_next_level)
	
	if player_ship:
		_update_hp_display(player_ship.health, player_ship.max_hp)
	call_deferred("_setup_skills")

# --- THE UPDATE FUNCTIONS ---

func _update_gold_display(new_gold: int) -> void:
	gold_label.text = "Gold: " + str(new_gold)

func _update_level_display(new_level: int) -> void:
	level_label.text = "Level " + str(new_level)

# Progress Bars use .value and .max_value instead of text!
func _update_xp_display(current_xp: int, max_xp: int) -> void:
	xp_bar.max_value = max_xp
	xp_bar.value = current_xp

func _update_hp_display(health: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = health

func _setup_skills() -> void:
	if not player_ship: return
	
	var skill_manager = player_ship.get_node_or_null("SkillManager")
	if not skill_manager: return
	
	# Grab lists of both the UI slots and the actual equipped skills
	var ui_slots = icon_container.get_children()
	var equipped_skills = skill_manager.get_children()
	
	# 2. THE DYNAMIC LOOP
	# Go through every single UI slot we placed in the editor...
	for i in range(ui_slots.size()):
		var icon = ui_slots[i]
		
		# Does the player actually have a skill for this slot?
		if i < equipped_skills.size():
			# Yes! Assign the skill to the icon and make sure it's visible.
			icon.assign_skill(equipped_skills[i])
			icon.show() 
		else:
			# No! The player only has 1 skill, but we have 4 UI slots.
			# Hide the extra empty slots so the screen looks clean.
			icon.hide()
