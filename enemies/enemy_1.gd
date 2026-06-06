extends CharacterBody2D

var player: Node2D = null

@export_group("Stats")
@export var health: int = 100
@export var speed: float = 100.0
@export var turn_speed: float = 2.0 # NEW: How fast it rotates. Lower = more sluggish!
@export var fire_rate: float = 2.0
@export var xp_reward: int = 25

@export_group("Assets")
@export var destroyed_image: Texture2D
@export var loot_drop_scene: PackedScene

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
var is_destroyed = false

func _ready() -> void:
	# Find the player in the scene tree using the group we created
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# If the ship is dead, or the player doesn't exist, do nothing
	if is_destroyed or not player:
		return
	# --- AI MOVEMENT ---
	# Calculate the normalized vector pointing from the enemy to the player
	var target_dir = global_position.direction_to(player.global_position)
	var target_angle = target_dir.angle()
	
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_and_slide()

func take_damage(amount: int):
	if is_destroyed:
		return 
		
	health -= amount
	
	if health <= 0:
		explode()

func explode():
	is_destroyed = true
	
	PlayerData.add_xp(xp_reward)
	
	if destroyed_image:
		sprite.texture = destroyed_image
		# --- NEW LOOT DROP LOGIC ---
	if loot_drop_scene:
		var chest = loot_drop_scene.instantiate()
		
		# Set the chest's location to be exactly where the enemy died
		chest.global_position = global_position 
		
		# Add the chest to the main game world (not as a child of the dying enemy!)
		get_tree().current_scene.call_deferred("add_child", chest)
	# ---------------------------
	collision.set_deferred("disabled", true)
	remove_from_group("enemies")
	
	await get_tree().create_timer(1.0).timeout
	
	queue_free()
