extends CharacterBody2D

var player: Node2D = null
@export var destroyed_image: Texture2D
@export var xp_reward: int = 25 
@export var loot_drop_scene: PackedScene
@export var speed: float = 150.0
@export var fire_rate: float = 2.0
var health = 100
var is_destroyed = false

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

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
	
	velocity = target_dir * speed
	rotation = velocity.angle()
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
		get_tree().current_scene.add_child(chest)
	# ---------------------------
	collision.set_deferred("disabled", true)
	remove_from_group("enemies")
	
	await get_tree().create_timer(3.0).timeout
	
	queue_free()
