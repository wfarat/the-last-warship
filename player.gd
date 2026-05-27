extends CharacterBody2D

const SPEED = 300.0
const ROTATION_SPEED = 3.0 

@export var bullet_scene: PackedScene 

# Get references to our new Cannon structure
@onready var cannon = $Cannon
@onready var muzzle = $Cannon/Muzzle

func _physics_process(delta: float) -> void:
	# 1. Ship Movement (Exactly the same as before)
	var turn_direction := Input.get_axis("ui_left", "ui_right")
	rotation += turn_direction * ROTATION_SPEED * delta

	var move_direction := Input.get_axis("ui_down", "ui_up")
	var forward_vector = Vector2.UP.rotated(rotation)

	if move_direction:
		velocity = forward_vector * move_direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 10.0)

	move_and_slide()

	# 2. Cannon Aiming
	# Find the angle from the cannon's current position to the mouse.
	var angle_to_mouse = cannon.global_position.direction_to(get_global_mouse_position()).angle()
	
	# Godot calculates angles assuming "Right" is forward. 
	# Because our sprites point "Up", we add PI/2 (90 degrees in radians) to correct it.
	cannon.global_rotation = angle_to_mouse + (PI / 2.0)


func _unhandled_input(event: InputEvent) -> void:
	# Check if the event is a mouse button click
	if event is InputEventMouseButton:
		# If it is the Left Mouse Button and it was just pressed down
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			shoot()

func shoot():
	var spawned_bullet = bullet_scene.instantiate()
	spawned_bullet.global_position = muzzle.global_position
	spawned_bullet.global_rotation = cannon.global_rotation
	
	get_tree().current_scene.add_child(spawned_bullet)
	
	# Play the shooting animation
	cannon.play("shoot")
	
	# Wait for the 6 frames to finish playing
	await cannon.animation_finished
	
	# Return to the default non-shooting frame
	cannon.play("idle")
