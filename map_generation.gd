extends Node2D

@export var noise_height_text : NoiseTexture2D
@export var player : Node2D
var noise : Noise

# --- Chunk Variables ---
var CHUNK_SIZE : int = 32 # A chunk is 32x32 tiles
var TILE_SIZE_PIXELS : int = 16
var RENDER_DISTANCE : int = 2 # Generates a 5x5 grid of chunks around the player (2 chunks in every direction)
var UNLOAD_DISTANCE : int = 4 # How many chunks away before we delete it (must be > RENDER_DISTANCE)

var active_chunks = {} # A dictionary to remember which chunks are loaded
var current_player_chunk = Vector2i.ZERO # Tracks the chunk the ship is currently sailing in

@onready var water_tilemaplayer: TileMapLayer = $WaterTileMapLayer
@onready var grass_tilemaplayer: TileMapLayer = $GrassTileMapLayer
@onready var sand_tilemaplayer: TileMapLayer = $SandTileMapLayer

var source_id = 0
var water_atlas_arr = [Vector2i(2,0),Vector2i(3,0),Vector2i(4,0),Vector2i(5,0),Vector2i(6,0)]
var grass_atlas_arr = [Vector2i(2,0),Vector2i(3,0),Vector2i(2,2),Vector2i(3,2)]
var sand_atlas_arr = [Vector2i(6,0),Vector2i(7,0),Vector2i(8,0),Vector2i(9,0)]

func _ready() -> void:
	noise = noise_height_text.noise
	#generate_world()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	
	# Calculate the actual world tile coordinates where this chunk begins
	var start_x = chunk_coord.x * CHUNK_SIZE
	var start_y = chunk_coord.y * CHUNK_SIZE
	
	# Loop ONLY through the bounds of this specific chunk
	for x in range(start_x, start_x + CHUNK_SIZE):
		for y in range(start_y, start_y + CHUNK_SIZE):
			
			var noise_val :float = noise.get_noise_2d(x, y)
			
			# Place Water
			water_tilemaplayer.set_cell(Vector2i(x, y), source_id, water_atlas_arr.pick_random())
			
			# Place Sand/Grass based on noise
			if noise_val >= 0.15 and noise_val < 0.2:
				sand_tilemaplayer.set_cell(Vector2i(x, y), source_id, sand_atlas_arr.pick_random())
			elif noise_val >= 0.2:
				grass_tilemaplayer.set_cell(Vector2i(x, y), source_id, grass_atlas_arr.pick_random())
				
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
