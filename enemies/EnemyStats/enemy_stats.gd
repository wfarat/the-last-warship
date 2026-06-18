extends Resource
class_name EnemyStats

@export_group("Stats")
@export var max_health: int = 100
@export var speed: float = 100.0
@export var turn_speed: float = 2.0 # NEW: How fast it rotates. Lower = more sluggish!
@export var xp_reward: int = 25

@export_group("Assets")
@export var destroyed_image: Texture2D
