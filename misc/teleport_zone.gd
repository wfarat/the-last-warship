extends Area2D

@export var dock_target: Marker2D 
@export var cooldown_time: float = 10.0
var can_teleport: bool = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and can_teleport:
		can_teleport = false
		body.global_position = dock_target.global_position
		body.global_rotation = dock_target.global_rotation
		body.velocity = Vector2.ZERO 
		await get_tree().create_timer(cooldown_time).timeout
		can_teleport = true
