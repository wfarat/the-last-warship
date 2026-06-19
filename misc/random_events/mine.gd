extends Area2D

@export var mine_damage: int = 100
@onready var explosion_effect: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite: Sprite2D =  $Sprite2D

func _ready() -> void:
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)
	explosion_effect.hide()

func _on_body_entered(body: Node2D) -> void:
	# Because of our physics mask, this will ONLY trigger for the player!
	if body.has_method("take_damage"):
		body.take_damage(mine_damage)
		
	trigger_explosion()

func trigger_explosion() -> void:
	if explosion_effect:
		sprite.hide()
		explosion_effect.show()
		explosion_effect.play("default")
		await get_tree().create_timer(0.5).timeout
	# Play explosion sound via global sound manager if you have one
	queue_free()
