extends CharacterBody2D

const SPEED = 300.0
const ROTATION_SPEED = 3.0 

func _physics_process(delta: float) -> void:
	# Just steering and driving!
	var turn_direction := Input.get_axis("ui_left", "ui_right")
	rotation += turn_direction * ROTATION_SPEED * delta

	var move_direction := Input.get_axis("ui_down", "ui_up")
	var forward_vector = Vector2.UP.rotated(rotation)

	if move_direction:
		velocity = forward_vector * move_direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 10.0)

	move_and_slide()

func install_cannon(slot_index: int, new_cannon_scene: PackedScene):
	# Grab the parent folder holding all your Marker2D slots
	var slots_folder = $Slots 
	
	# Find the specific Marker2D using the number the Shop gave us
	var target_slot = slots_folder.get_child(slot_index)
	
	# 1. Delete whatever is currently in that slot
	for child in target_slot.get_children():
		child.queue_free()
		
	# 2. Spawn the new cannon blueprint
	var new_cannon = new_cannon_scene.instantiate()
	
	# 3. Add it to the exact Marker2D slot
	target_slot.add_child(new_cannon)
