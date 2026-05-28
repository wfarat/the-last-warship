extends StaticBody2D

@export var shop_hud: CanvasLayer

# Our safety switch. It starts as true.
var can_shop: bool = true 

func _on_dock_sensor_body_entered(body: Node2D) -> void:
	# Now we check if it's the player AND if the switch is ON
	if body.is_in_group("player") and can_shop == true:
		
		can_shop = false # Flip the switch OFF so it can't trigger again
		
		shop_hud.open_shop(body) 
		get_tree().paused = true


# This runs the exact moment the ship stops touching the rectangle
func _on_dock_sensor_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		
		can_shop = true # Flip the switch back ON for the next visit!
