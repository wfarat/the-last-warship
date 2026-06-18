extends Node2D

@export var noise_height_text : NoiseTexture2D
@export var player : Node2D
@export var port_scene : PackedScene
var noise : Noise

@export var port_chance : float = 0.15
@export var SEA_LEVEL : float = 0.35
@export var GRASS_LEVEL : float = 0.4
@export var port_water_offset: float = 64.0 

# --- Chunk Variables ---
var CHUNK_SIZE : int = 64 # A chunk is 32x32 tiles
var TILE_SIZE_PIXELS : int = 16
var RENDER_DISTANCE : int = 2 # Generates a 5x5 grid of chunks around the player (2 chunks in every direction)
var UNLOAD_DISTANCE : int = 4 # How many chunks away before we delete it (must be > RENDER_DISTANCE)

var active_chunks = {} # A dictionary to remember which chunks are loaded
var current_player_chunk = Vector2i.ZERO # Tracks the chunk the ship is currently sailing in
var chunk_entities = {} # Keeps track of spawned scenes per chunk (like ports, enemies, loot)

@onready var water_tilemaplayer: TileMapLayer = $WaterTileMapLayer
@onready var grass_tilemaplayer: TileMapLayer = $GrassTileMapLayer
@onready var sand_tilemaplayer: TileMapLayer = $SandTileMapLayer

var source_id = 0
var water_atlas_arr = [Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0),Vector2i(6,0)]
var grass_atlas_arr = [Vector2i(2,0),Vector2i(3,0),Vector2i(2,2),Vector2i(3,2)]
var sand_atlas_arr = [Vector2i(6,0),Vector2i(7,0),Vector2i(8,0),Vector2i(9,0)]
var noise_val_arr = []
func _ready() -> void:
	noise = noise_height_text.noise

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if player:
		update_chunks()

func update_chunks():
	# 1. Convert the player's pixel position to a global Tile position
	var player_tile_pos = player.global_position / TILE_SIZE_PIXELS
	
	# 2. Convert the Tile position to a Chunk coordinate (e.g., Chunk(1, -2))
	var new_player_chunk = Vector2i(
		floor(player_tile_pos.x / CHUNK_SIZE), 
		floor(player_tile_pos.y / CHUNK_SIZE)
	)
	
	# 3. Only run the heavy math if the ship actually crossed a chunk border
	if new_player_chunk != current_player_chunk or active_chunks.is_empty():
		current_player_chunk = new_player_chunk
		
		# Loop through a grid around the player based on the render distance
		for x in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
			for y in range(-RENDER_DISTANCE, RENDER_DISTANCE + 1):
				var chunk_to_check = current_player_chunk + Vector2i(x, y)
				generate_chunk(chunk_to_check)
		unload_far_chunks()

func generate_chunk(chunk_coord: Vector2i):
	# If this chunk is already in our dictionary, don't generate it again
	if active_chunks.has(chunk_coord):
		return
		
	# Add it to the dictionary so we know it exists
	active_chunks[chunk_coord] = true
	
	var chunk_rng = RandomNumberGenerator.new()
	chunk_rng.seed = hash(chunk_coord)
	var has_port = chunk_rng.randf() < port_chance
	var potential_port_spots = []
	# Calculate the actual world tile coordinates where this chunk begins
	var start_x = chunk_coord.x * CHUNK_SIZE
	var start_y = chunk_coord.y * CHUNK_SIZE
	
	# Loop ONLY through the bounds of this specific chunk
	for x in range(start_x, start_x + CHUNK_SIZE):
		for y in range(start_y, start_y + CHUNK_SIZE):
			
			var noise_val :float = noise.get_noise_2d(x, y)
			noise_val_arr.append(noise_val)
			# Place Water
			water_tilemaplayer.set_cell(Vector2i(x, y), source_id, water_atlas_arr.pick_random())
			# Place Sand/Grass based on noise
			if noise_val >= SEA_LEVEL and noise_val < GRASS_LEVEL:
				sand_tilemaplayer.set_cell(Vector2i(x, y), source_id, sand_atlas_arr.pick_random())
				if has_port:
					potential_port_spots.append(Vector2i(x, y))
			elif noise_val >= GRASS_LEVEL:
				grass_tilemaplayer.set_cell(Vector2i(x, y), source_id, grass_atlas_arr.pick_random())
# Spawn the Port
	if has_port and potential_port_spots.size() > 0:
		
		# Give it 10 tries to find a good beach. If it fails 10 times, 
		# this chunk just gets no port (prevents infinite loops!).
		var attempts = 10 
		var port_spawned = false
		
		while attempts > 0 and not port_spawned:
			attempts -= 1
			
			# Pick a random sand tile
			var chosen_sand = potential_port_spots[chunk_rng.randi() % potential_port_spots.size()]
			var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
			
			for dir in directions:
				# Probe 1, 2, and 3 tiles out into the ocean
				var step_1 = chosen_sand + dir
				var step_2 = chosen_sand + (dir * 2)
				var step_3 = chosen_sand + (dir * 3)
				
				# Check if ALL THREE steps are valid water
				var is_open_ocean = (
					noise.get_noise_2d(step_1.x, step_1.y) < SEA_LEVEL and
					noise.get_noise_2d(step_2.x, step_2.y) < SEA_LEVEL and
					noise.get_noise_2d(step_3.x, step_3.y) < SEA_LEVEL
				)
				
				if is_open_ocean:
					# We found a clear channel! 
					# NOTE: We pass 'dir' to the function now!
					spawn_port(step_1, chunk_coord, dir) 
					port_spawned = true
					break # Stop looking in other directions
func unload_far_chunks():
	var chunks_to_remove = []
	
	# 1. Look through every chunk we currently have loaded
	for chunk_coord in active_chunks.keys():
		
		# Calculate how far this chunk is from the player on the abstract grid
		var distance_x = abs(chunk_coord.x - current_player_chunk.x)
		var distance_y = abs(chunk_coord.y - current_player_chunk.y)
		
		# If it's outside our safe buffer zone, mark it for death
		if distance_x > UNLOAD_DISTANCE or distance_y > UNLOAD_DISTANCE:
			chunks_to_remove.append(chunk_coord)
			
	# 2. Delete the marked chunks
	for chunk_coord in chunks_to_remove:
		remove_chunk(chunk_coord)
		active_chunks.erase(chunk_coord) # Remove it from our memory dictionary

func remove_chunk(chunk_coord: Vector2i):
	var start_x = chunk_coord.x * CHUNK_SIZE
	var start_y = chunk_coord.y * CHUNK_SIZE
	
	# Loop through the exact same bounds we used to generate it
	for x in range(start_x, start_x + CHUNK_SIZE):
		for y in range(start_y, start_y + CHUNK_SIZE):
			
			var tile_pos = Vector2i(x, y)
			
			# erase_cell() is Godot's built-in way to clear a tile and its physics
			water_tilemaplayer.erase_cell(tile_pos)
			sand_tilemaplayer.erase_cell(tile_pos)
			grass_tilemaplayer.erase_cell(tile_pos)
	if chunk_entities.has(chunk_coord):
		for entity in chunk_entities[chunk_coord]:
			if is_instance_valid(entity):
				entity.queue_free()
				
		chunk_entities.erase(chunk_coord)


func spawn_port(tile_pos: Vector2i, chunk_coord: Vector2i, dir: Vector2i) -> void:
	if port_scene == null:
		push_warning("Port Scene is not assigned in MapGenerator!")
		return
		
	var port_instance = port_scene.instantiate()
	
	# 1. Calculate the exact center of the sand tile
	var base_offset = Vector2(TILE_SIZE_PIXELS / 2.0, TILE_SIZE_PIXELS / 2.0)
	var center_position = (Vector2(tile_pos) * TILE_SIZE_PIXELS) + base_offset
	
	# 2. THE NUDGE
	# Vector2(dir) is already pointing at the water (e.g., Vector2(1, 0) for Right).
	# Multiplying it by our offset scales that step into pixels!
	var water_nudge = Vector2(dir) * port_water_offset
	
	# Apply both the center position and the nudge
	port_instance.position = center_position + water_nudge
	
	# 3. Rotate the Port
	port_instance.rotation = Vector2(dir).angle() - (PI / 2.0)	
	# 4. Add to the World
	add_child(port_instance)
	
	# 5. Store it for chunk unloading
	if not chunk_entities.has(chunk_coord):
		chunk_entities[chunk_coord] = []
		
	chunk_entities[chunk_coord].append(port_instance)

func is_water(global_pixel_position: Vector2) -> bool:
	var tile_x = floor(global_pixel_position.x / TILE_SIZE_PIXELS)
	var tile_y = floor(global_pixel_position.y / TILE_SIZE_PIXELS)
	
	#Check the noise at that exact tile
	var noise_val = noise.get_noise_2d(tile_x, tile_y)
	
	#Return true if it's below your established sea level
	return noise_val < SEA_LEVEL
