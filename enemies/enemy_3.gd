extends CharacterBody2D

var player: Node2D = null

enum State { CHASE, WINDUP, CHARGE, COOLDOWN }
var current_state: State = State.CHASE

@export_group("Base Stats")
@export var health: int = 150
@export var speed: float = 80.0
@export var turn_speed: float = 1.5 
@export var xp_reward: int = 40 

@export_group("Ramming Mechanics")
@export var charge_speed: float = 400.0
@export var windup_time: float = 0.6 # Gives player time to react!
@export var charge_duration: float = 1.5 # How long the charge lasts if they miss
@export var cooldown_time: float = 10.0
@export var base_ram_damage: float = 10.0
@export var speed_damage_multiplier: float = 0.1 # Extra damage per unit of speed

var state_timer: float = 0.0
var is_destroyed: bool = false

@export var destroyed_image: Texture2D
@export var loot_drop_scene: PackedScene

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var vision_ray: RayCast2D = $RayCast2D
@onready var charge_effect: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	charge_effect.hide()

func _physics_process(delta: float) -> void:
	if is_destroyed or not player:
		return
		
	# Always aim the raycast at the player
	vision_ray.target_position = to_local(player.global_position)
		
	# State Machine handles what the ship does right now
	match current_state:
		State.CHASE:
			process_chase(delta)
		State.WINDUP:
			process_windup(delta)
		State.CHARGE:
			process_charge(delta)
		State.COOLDOWN:
			process_cooldown(delta)
			
	# Move the ship and check if we rammed anything!
	var collided = move_and_slide()
	if collided and current_state == State.CHARGE:
		handle_ram_impact()

# --- STATE LOGIC ---

func process_chase(delta: float):
	# Standard sluggish movement
	var target_dir = global_position.direction_to(player.global_position)
	rotation = lerp_angle(rotation, target_dir.angle(), turn_speed * delta)
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	# Check if we have a clear line of sight to start a charge
	if vision_ray.is_colliding():
		var hit_object = vision_ray.get_collider()
		if hit_object == player:
			change_state(State.WINDUP)

func process_windup(delta: float):
	# Stop moving, lock rotation, and prepare to fire!
	velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
	state_timer -= delta
	
	if state_timer <= 0:
		change_state(State.CHARGE)

func process_charge(delta: float):
	# Instantly accelerate in a straight line. NO rotation updating here!
	velocity = Vector2.RIGHT.rotated(rotation) * charge_speed
	state_timer -= delta
	
	if state_timer <= 0:
		change_state(State.COOLDOWN) # Missed the player!

func process_cooldown(delta: float):
	# Move normally, but prevent charging again until timer is done
	var target_dir = global_position.direction_to(player.global_position)
	rotation = lerp_angle(rotation, target_dir.angle(), (turn_speed * 0.5) * delta) # Turns even slower while recovering
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	
	state_timer -= delta
	if state_timer <= 0:
		change_state(State.CHASE)

func change_state(new_state: State):
	current_state = new_state
	
	# Handle what happens the exact moment a state begins
	match current_state:
		State.WINDUP:
			state_timer = windup_time
			charge_effect.show()
			charge_effect.play("windup") # Optional windup animation
		State.CHARGE:
			state_timer = charge_duration
			#charge_effect.play("charging")
		State.COOLDOWN:
			state_timer = cooldown_time
			charge_effect.hide()
			charge_effect.stop()
			
# --- COMBAT LOGIC ---

func handle_ram_impact():
	# Loop through everything the ship bumped into this frame
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var hit_body = collision_info.get_collider()
		
		if hit_body.is_in_group("player"):
			if hit_body.has_method("take_damage"):
				# Calculate damage based on how fast we were going!
				var impact_speed = velocity.length()
				var total_damage = base_ram_damage + (impact_speed * speed_damage_multiplier)
				
				hit_body.take_damage(int(total_damage))
				
			# Bounce off the player and go into cooldown
			velocity = -velocity * 0.5 
			change_state(State.COOLDOWN)
			break
		elif not hit_body.is_in_group("enemies"):
			# We hit an island/wall! Stop the charge.
			change_state(State.COOLDOWN)
			break

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
