extends Node2D

@export_group("Spawning Parameters")
@export var enemy_scenes: Array[PackedScene] 
@export var spawn_radius_min: float = 800.0 # Just off-screen
@export var spawn_radius_max: float = 1200.0 # Not too far away
@export var max_spawn_attempts: int = 10

@export_group("Boss Settings")
@export var boss_scene: PackedScene
@export var levels_between_bosses: int = 5

@onready var player = $Player
@onready var map_generation: Node2D = $map_generation
@onready var timer: Timer = $Timer

var game_time: float = 0.0
var active_spawn_pool: Array[PackedScene] = []

func _ready() -> void:
	# Ensure the timer is running when the game starts
	if timer.is_stopped():
		timer.start()
	PlayerData.leveled_up.connect(_on_player_level_up)
	active_spawn_pool.append(enemy_scenes[0])

func _process(delta: float) -> void:
	# 2. Keep track of exactly how many seconds have passed
	game_time += delta
	update_difficulty()
	
func update_difficulty() -> void:
	# --- DYNAMIC SPAWN RATE ---
	# Formula: Start at 2.5 seconds. Every 10 seconds of gameplay, subtract 0.05 seconds.
	# The max() function ensures it never drops below 0.3 seconds (so it doesn't crash the game!)
	var new_wait_time = max(0.3, 2.5 - (game_time / 200.0))
	
	# Update the timer only if the value has changed significantly
	if abs(timer.wait_time - new_wait_time) > 0.05:
		timer.wait_time = new_wait_time

	# --- ENEMY UNLOCKS ---
	if game_time < 130.0:
		if game_time > 60.0 and enemy_scenes[1] not in active_spawn_pool:
			active_spawn_pool.append(enemy_scenes[1])
		if game_time > 120.0 and enemy_scenes[2] not in active_spawn_pool:
			active_spawn_pool.append(enemy_scenes[2])

func _on_player_level_up(new_level: int) -> void:
	# Use modulo (%) to check if the level is perfectly divisible by 5
	if new_level % levels_between_bosses == 0:
		spawn_boss()
		
func _on_timer_timeout() -> void:
	if active_spawn_pool.is_empty() or not player:
		return

	# Pick a random enemy from our currently unlocked pool
	var random_enemy_scene = active_spawn_pool.pick_random()
	var safe_spawn_pos = get_valid_water_spawn()
	
	if safe_spawn_pos != Vector2.INF:
		var enemy_instance = random_enemy_scene.instantiate()
		enemy_instance.global_position = safe_spawn_pos
		add_child(enemy_instance)
	else:
		# If the player is surrounded by huge islands, we skip spawning this tick 
		# so the game doesn't crash or trap enemies on land.
		print("Spawn failed: Too much land around the player this tick!")

func get_valid_water_spawn() -> Vector2:
	for attempt in range(max_spawn_attempts):
		# Pick a random angle (TAU is Godot's constant for 360 degrees in math)
		var random_angle = randf() * TAU
		
		# Pick a random distance inside our donut shape
		var random_distance = randf_range(spawn_radius_min, spawn_radius_max)
		
		# Calculate the final coordinate relative to the player
		var offset = Vector2.RIGHT.rotated(random_angle) * random_distance
		var potential_spawn_pos = player.global_position + offset
		
		# Ask the MapGenerator if this exact pixel is in the water
		if map_generation.is_water(potential_spawn_pos):
			return potential_spawn_pos
			
	# Return an invalid vector if we couldn't find water after 10 tries
	return Vector2.INF

func spawn_boss():
	# Use the same Donut Spawning logic we created earlier, 
	# but maybe push the boss slightly further away so they don't spawn on top of the player!
	var max_attempts = 20
	var spawn_distance = spawn_radius_max + 200.0 
	
	for attempt in range(max_attempts):
		var random_angle = randf() * TAU
		var offset = Vector2.RIGHT.rotated(random_angle) * spawn_distance
		var potential_spawn_pos = player.global_position + offset
		
		# Check if the massive ship has water to spawn in!
		if map_generation.is_water(potential_spawn_pos):
			var boss_instance = boss_scene.instantiate()
			boss_instance.global_position = potential_spawn_pos
			call_deferred("add_child", boss_instance)
			
			# Optional: Play a warning siren or show a UI warning here!
			print("WARNING: Battleship approaching!")
			return # Successfully spawned, stop looping
			
	print("Boss spawn failed: Couldn't find a big enough ocean!")
