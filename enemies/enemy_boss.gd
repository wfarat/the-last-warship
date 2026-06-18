extends CharacterBody2D

var player: Node2D = null

@export_group("Boss Stats")
@export var health: int = 1500
@export var speed: float = 40.0 # Very slow!
@export var turn_speed: float = 0.1 # Turns like a brick
@export var optimal_range: float = 400.0 # Distance to start circling
@export var xp_reward: int = 500

var is_destroyed = false
@onready var sprite = $Sprite2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if is_destroyed or not player:
		return
		
	var distance_to_player = global_position.distance_to(player.global_position)
	var dir_to_player = global_position.direction_to(player.global_position)
	var target_angle = 0.0
	
	# AI DECISION: Chase or Broadside?
	if distance_to_player > optimal_range:
		# Too far: Point the nose at the player to chase them down
		target_angle = dir_to_player.angle()
	else:
		# In range: Turn the ship sideways (add 90 degrees) to orbit and fire side cannons!
		# PI / 2.0 is exactly 90 degrees in radians.
		target_angle = dir_to_player.angle() + (PI / 2.0) 

	# Smoothly rotate the massive ship
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	
	# Always move forward in the direction the nose is currently pointing
	# (Change Vector2.RIGHT to Vector2.UP if your ship sprite faces up!)
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	move_and_slide()

func take_damage(amount: int):
	if is_destroyed: return 
	health -= amount
	if health <= 0:
		explode()

func explode():
	is_destroyed = true
	PlayerData.add_xp(xp_reward)
	# Add your massive explosion effects and loot drops here!
	queue_free()
