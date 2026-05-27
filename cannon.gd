extends AnimatedSprite2D

@export var bullet_scene: PackedScene 
@export var fire_rate: float = 0.5 

var current_cooldown: float = 0.0

# Since the script is on the Cannon, Muzzle is just a direct child
@onready var muzzle = $Muzzle

func _physics_process(delta: float) -> void:
	var angle_to_mouse = global_position.direction_to(get_global_mouse_position()).angle()
	global_rotation = angle_to_mouse + (PI / 2.0)

	if current_cooldown > 0.0:
		current_cooldown -= delta
		
	if current_cooldown <= 0.0:
		shoot()
		current_cooldown = fire_rate

func shoot():
	if not bullet_scene:
		return 
		
	var spawned_bullet = bullet_scene.instantiate()
	spawned_bullet.global_position = muzzle.global_position
	spawned_bullet.global_rotation = global_rotation
	
	get_tree().current_scene.add_child(spawned_bullet)
	
	play("shoot")
	await animation_finished
	play("idle")
