extends Area2D

@export var dock_target: Marker2D 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.global_position = dock_target.global_position
		body.global_rotation = dock_target.global_rotation
		body.velocity = Vector2.ZERO 
