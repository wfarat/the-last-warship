extends CanvasLayer

@onready var gold_label = $MarginContainer/VBoxContainer/GoldLabel
@onready var level_label = $MarginContainer/VBoxContainer/LevelLabel
@onready var xp_bar = $MarginContainer/VBoxContainer/XPBar
@onready var hp_bar = $MarginContainer/VBoxContainer/HPBar
@onready var first_skill_icon = $SkillBar/HBoxContainer/LPM/SkillIcon
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
	
	# Find the SkillManager on the player
	var skill_manager = player_ship.get_node_or_null("SkillManager")
	
	if skill_manager and skill_manager.get_child_count() > 0:
		var skill_1 = skill_manager.get_child(0)
		
		first_skill_icon.assign_skill(skill_1)
