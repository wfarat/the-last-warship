extends Node2D

# This allows you to drag and drop your Enemy scene in the Inspector
@export var enemy_scene: PackedScene 

# This function runs every time the Timer hits 0 (every 3 seconds)
func _on_timer_timeout() -> void:
	# 1. Create a new instance of the enemy
	var spawned_enemy = enemy_scene.instantiate()
	
	# 2. Pick a random X and Y coordinate. 
	# (Adjust these numbers to match how big you made your water background!)
	var random_x = randf_range(-1500.0, 1500.0)
	var random_y = randf_range(-1500.0, 1500.0)
	
	# 3. Set the enemy's position to those random coordinates
	spawned_enemy.global_position = Vector2(random_x, random_y)
	
	# 4. Add the enemy to the Main scene
	add_child(spawned_enemy)
