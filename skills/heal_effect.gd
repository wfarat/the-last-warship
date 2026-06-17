extends AnimatedSprite2D

func _ready() -> void:
	play("heal")
	
	animation_finished.connect(queue_free)
