extends Area2D

@export_group("Tornado Stats")
@export var move_speed: float = 30.0 # How fast the tornado chases the player
@export var pull_speed: float = 100.0 # How fast ships are dragged in
@export var min_duration: float = 10.0
@export var max_duration: float = 20.0
@export var tornado_damage: int = 15
@export var damage_tick_rate: float = 0.5

var active_ships: Array[CharacterBody2D] = []
var damage_timer: float = 0.0
var player: Node2D = null

@onready var damage_zone: Area2D = $DamageZone
@onready var pull_zone: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	var lifetime = randf_range(min_duration, max_duration)
	get_tree().create_timer(lifetime).timeout.connect(on_lifetime_expired)
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
		
	# Ensure this Area checks for Players (Layer 1) and Enemies (Layer 2)
	collision_mask = 1 | 2 
	damage_zone.collision_mask = 1 | 2

func _physics_process(delta: float) -> void:
	if is_instance_valid(player):
		var dir_to_player = global_position.direction_to(player.global_position)
		# Move the tornado itself!
		global_position += dir_to_player * move_speed * delta
	# 1. Apply Pulling Force to all ships within the outer radius
	for ship in active_ships:
		if is_instance_valid(ship):
			# Calculate direction FROM the ship TO the tornado
			var dir_to_center = ship.global_position.direction_to(global_position)
			var distance = global_position.distance_to(ship.global_position)
			
			# Make the pull stronger the closer the ship gets to the eye
			var current_radius = pull_zone.shape.radius
			var force_modifier = 1.0 - (distance / current_radius)
			force_modifier = clamp(force_modifier, 0.1, 1.0)
			
			# THE FIX: Directly drag their physical position!
			# This forces them backward even if their AI is trying to drive away.
			ship.global_position += dir_to_center * (pull_speed * force_modifier) * delta

	# 2. Handle Damage Over Time for ships in the center eye
	damage_timer += delta
	if damage_timer >= damage_tick_rate:
		damage_timer = 0.0
		for body in damage_zone.get_overlapping_bodies():
			if body.has_method("take_damage"):
				body.take_damage(tornado_damage)

# Track who enters/leaves the pulling zone using Area2D signals
func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		active_ships.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body in active_ships:
		active_ships.erase(body)

func on_lifetime_expired() -> void:
	# Fade out effects here before destroying
	queue_free()
