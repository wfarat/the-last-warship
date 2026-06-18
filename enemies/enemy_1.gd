extends CharacterBody2D

var player: Node2D = null
@export var stats: Resource

@onready var cannon = $slot
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
var is_destroyed = false
var health: int

func _ready() -> void:
	# Find the player in the scene tree using the group we created
	health = stats.max_health
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# If the ship is dead, or the player doesn't exist, do nothing
	if is_destroyed or not player:
		return
	# --- AI MOVEMENT ---
	# Calculate the normalized vector pointing from the enemy to the player
	var target_dir = global_position.direction_to(player.global_position)
	var target_angle = target_dir.angle()
	
	rotation = lerp_angle(rotation, target_angle, stats.turn_speed * delta)
	velocity = Vector2.RIGHT.rotated(rotation) * stats.speed
	move_and_slide()

func take_damage(amount: int):
	if is_destroyed:
		return 
		
	health -= amount
	
	if health <= 0:
		explode()

func explode():
	is_destroyed = true
	cannon.queue_free()
	PlayerData.add_xp(stats.xp_reward)
	ScoreManager.add_kill()
	if stats.destroyed_image:
		sprite.texture = stats.destroyed_image
	GameManager.spawn_loot(global_position)
	collision.set_deferred("disabled", true)
	remove_from_group("enemies")
	
	await get_tree().create_timer(1.0).timeout
	
	queue_free()
