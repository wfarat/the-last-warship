extends Node
class_name Skill

@export var skill_name: String = "Base Skill"
@export var icon: Texture2D
@export var base_cooldown: float = 10.0
@export var max_level: int = 3

var current_level: int = 1
var current_cooldown: float = 0.0
var is_ready: bool = true

# These signals tell the HUD to update cooldown sweeps or level stars!
signal skill_activated
signal cooldown_updated(time_left, max_time)
signal skill_upgraded(new_level)

func _process(delta: float) -> void:
	if not is_ready:
		current_cooldown -= delta
		cooldown_updated.emit(current_cooldown, base_cooldown)
		
		if current_cooldown <= 0.0:
			is_ready = true
			current_cooldown = 0.0

# The player presses a button to call this function
func execute(caster: Node2D, controller: bool) -> void:
	if is_ready:
		is_ready = false
		current_cooldown = base_cooldown
		skill_activated.emit()
		
		# Call the custom logic
		activate_effect(caster, controller)

# --- VIRTUAL FUNCTIONS (To be overridden by child scripts) ---

func activate_effect(_caster: Node2D, _controller: bool) -> void:
	pass # Child scripts replace this with explosions, dashes, etc.

func upgrade() -> void:
	if current_level < max_level:
		current_level += 1
		skill_upgraded.emit(current_level)
		apply_upgrade_stats()

func apply_upgrade_stats() -> void:
	pass # Child scripts replace this to lower cooldowns or increase damage
