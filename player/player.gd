extends CharacterBody2D

signal hp_changed(health, max_hp)
@onready var camera_2d: Camera2D = $Camera2D
const SPEED = 300.0
const ROTATION_SPEED = 3.0 

var max_hp: int = 10000
var health: int = 10000

@onready var skill_manager = $SkillManager

func _ready() -> void:
	if not PlayerData.saved_ship_data.is_empty():
		var ship_data = PlayerData.saved_ship_data
		
		global_position.x = ship_data.get("global_position_x", 0.0)
		global_position.y = ship_data.get("global_position_y", 0.0)
		health = ship_data.get("hp", max_hp)
		
		var saved_weapons = ship_data.get("weapons", [])
		for weapon_info in saved_weapons:
			var slot_idx = weapon_info["slot_index"]
			var cannon_scene = load(weapon_info["scene_path"])
			
			if cannon_scene:
				install_cannon(slot_idx, cannon_scene)
				var installed_cannon = $Slots.get_child(slot_idx).get_child(0)
				
				for t in range(weapon_info["tier"]):
					if installed_cannon.has_method("upgrade_tier"):
						installed_cannon.upgrade_tier()
		
		PlayerData.saved_ship_data = {}

func _unhandled_input(event: InputEvent) -> void:
	if GameManager.current_state != GameManager.GameState.PLAYING:
		return
	if event.is_action_pressed("skill_1"):
		if skill_manager.get_child_count() > 0:
			var skill = skill_manager.get_child(0)
			
			skill.execute(self)
	if event.is_action_pressed("skill_2"):
		if skill_manager.get_child_count() > 0:
			var skill = skill_manager.get_child(1)
			
			skill.execute(self)
			
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
	
	if slot_index % 2 == 0:
		new_cannon.rotation_degrees = -90 # Point Left
	else:
		new_cannon.rotation_degrees = 90  # Point Right
		
	# 4. Add it to the exact Marker2D slot
	target_slot.add_child(new_cannon)

func take_damage(amount: int):
	health -= amount
	hp_changed.emit(health, max_hp)
	
	if health <= 0:
		die()
		
func heal(amount: int) -> void:
	health = min(health + amount, max_hp)
	hp_changed.emit(health, max_hp)
	
func die():	
	if (GameManager.current_state != GameManager.GameState.GAME_OVER):
		GameManager.change_state(GameManager.GameState.GAME_OVER)
		GameManager.call_deferred("game_over")	
		queue_free()

func _input(_event):
	if Input.is_action_just_pressed("zoom_in"):
		var zoom_val = camera_2d.zoom.x - 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
  
	if Input.is_action_just_pressed("zoom_out"):
		var zoom_val = camera_2d.zoom.x + 0.1
		camera_2d.zoom = Vector2(zoom_val, zoom_val)
		
		
func get_save_data() -> Dictionary:
	var weapons_data = []
	var slots_folder = $Slots
	
	var slots = slots_folder.get_children()
	for i in range(slots.size()):
		var slot = slots[i]
		if slot.get_child_count() > 0:
			var weapon = slot.get_child(0)
			
			var weapon_info = {
				"slot_index": i,
				"scene_path": weapon.scene_file_path,
				"tier": weapon.current_tier
			}
			weapons_data.append(weapon_info)
	var skills_data = []
	for skill in $SkillManager.get_children():
		skills_data.append({
			"scene_path": skill.scene_file_path,
			"level": skill.current_level
		})
	return {
		"weapons": weapons_data,
		"skills": skills_data,
		"hp": health,
		"global_position_x": global_position.x,
		"global_position_y": global_position.y
	}
