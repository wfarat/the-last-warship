extends Node

var tornado_scene: PackedScene = preload("res://misc/random_events/tornado.tscn")
var mine_scene: PackedScene = preload("res://misc/random_events/mine.tscn")
var player: Node2D = null
var map_generation: Node2D = null

func attempt_random_event(event_chance: float) -> void:
	if randf() > event_chance:
		return # Failed the dice roll, stay peaceful
		
	# Pick a random event index
	var event_id = randi() % 2
	
	match event_id:
		0: trigger_tornado_event()
		1: trigger_minefield_event()

func announcement(id: int) -> void:
	# Play your global warning siren/sound
	# audio_player.play()
	print("event triggered", id)
	AudioManager.play_annoucement(id)
	# Automatically hide the splash announcement card after 3 seconds

# --- EVENT DEPLOYMENT ---

func trigger_tornado_event() -> void:
	announcement(0)
	
	# Spawn the tornado slightly off-screen but heading toward the player's general area
	var spawn_offset = Vector2.RIGHT.rotated(randf() * TAU) * 600.0
	var tornado = tornado_scene.instantiate()
	tornado.global_position = player.global_position + spawn_offset
	
	# Defer addition to bypass physics thread locks
	get_tree().current_scene.call_deferred("add_child", tornado)

func trigger_minefield_event() -> void:
	announcement(1)
	
	var mine_count = randi_range(15, 30)
	var spawn_radius = 500.0
	
	for i in range(mine_count):
		# Generate a random point within a circular ring around the player
		var random_direction = Vector2.RIGHT.rotated(randf() * TAU)
		var random_distance = randf_range(250.0, spawn_radius)
		var mine_pos = player.global_position + (random_direction * random_distance)
		
		# Check against your MapGenerator to make sure we don't spawn a mine inside an island tile!
		if map_generation.is_water(mine_pos):
			var mine = mine_scene.instantiate()
			mine.global_position = mine_pos
			get_tree().current_scene.call_deferred("add_child", mine)
