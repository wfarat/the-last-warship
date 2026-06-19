extends CharacterBody2D

var player: Node2D = null

enum State { CHASE, WINDUP, CHARGE, COOLDOWN }
var current_state: State = State.CHASE

@export var stats: Resource

@export_group("Ramming Mechanics")
@export var charge_speed: float = 400.0
@export var windup_time: float = 0.6 # Gives player time to react!
@export var charge_duration: float = 1.5 # How long the charge lasts if they miss
@export var cooldown_time: float = 10.0
@export var base_ram_damage: float = 10.0
@export var speed_damage_multiplier: float = 0.1 # Extra damage per unit of speed
@export var initial_spawn_cooldown: float = 3.0 # Waits 3 seconds after spawning
@export var damage_scale_per_level: float = 0.05
@export var health_scale_per_level: float = 0.15
var spawn_timer: float = initial_spawn_cooldown

var state_timer: float = 0.0
var is_destroyed: bool = false
var health: int
var current_ram_damage: int

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var vision_ray: RayCast2D = $RayCast2D
@onready var charge_effect: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	health = stats.max_health
	player = get_tree().get_first_node_in_group("player")
	charge_effect.hide()
	var p_level = PlayerData.level
	var health_multiplier = 1.0 + (p_level * health_scale_per_level)
	var damage_multiplier = 1.0 + (p_level * damage_scale_per_level)
	health = int(stats.max_health * health_multiplier)
	current_ram_damage = base_ram_damage * damage_multiplier

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
	var target_dir = global_position.direction_to(player.global_position)
	rotation = lerp_angle(rotation, target_dir.angle(), stats.turn_speed * delta)
	
	# NOTE: If your ship's sprite is drawn facing UP, change Vector2.RIGHT to Vector2.UP!
	var forward_vector = Vector2.RIGHT.rotated(rotation) 
	velocity = forward_vector * stats.speed
	
	# 1. Handle the Spawn Cooldown
	if spawn_timer > 0:
		spawn_timer -= delta
		return # Skip the attack checks until the timer is done!
	
	# 2. Check Line of Sight
	if vision_ray.is_colliding():
		var hit_object = vision_ray.get_collider()
		if hit_object == player:
			
			# 3. FIX THE MISS: Check if the ship is actually pointing at the player
			# .dot() compares the direction the ship is facing with the direction to the player.
			# > 0.98 means it's aiming within a very tight cone (almost perfectly straight ahead).
			if forward_vector.dot(target_dir) > 0.98:
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
	rotation = lerp_angle(rotation, target_dir.angle(), (stats.turn_speed * 0.5) * delta) # Turns even slower while recovering
	velocity = Vector2.RIGHT.rotated(rotation) * stats.speed
	
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
	for i in get_slide_collision_count():
		var collision_info = get_slide_collision(i)
		var hit_body = collision_info.get_collider()
		
		if hit_body.is_in_group("player"):
			if hit_body.has_method("take_damage"):
				# Calculate damage based on how fast we were going!
				var impact_speed = velocity.length()
				var total_damage = current_ram_damage + (impact_speed * speed_damage_multiplier)
				
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
	
	PlayerData.add_xp(stats.xp_reward)
	
	if stats.destroyed_image:
		sprite.texture = stats.destroyed_image
	GameManager.spawn_loot(global_position)
	collision.set_deferred("disabled", true)
	remove_from_group("enemies")
	
	await get_tree().create_timer(1.0).timeout
	
	queue_free()
