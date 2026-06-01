extends Area2D

@export var min_gold: int = 15
@export var max_gold: int = 50

@onready var water_mask = $WaterMask 
@onready var sprite = $WaterMask/Sprite2D # Note the updated path!
@onready var collision = $CollisionShape2D

var is_collected: bool = false
var bob_tween: Tween

func _ready() -> void:	
	bob_tween = create_tween().set_loops()
	bob_tween.tween_property(sprite, "position:y", -5.0, 1.5).as_relative().set_trans(Tween.TRANS_SINE)
	bob_tween.tween_property(sprite, "position:y", 5.0, 1.5).as_relative().set_trans(Tween.TRANS_SINE)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_collected:
		is_collected = true 
		
		collision.set_deferred("disabled", true)
		
		if bob_tween:
			bob_tween.kill()
			
		
		water_mask.clip_children = CanvasItem.CLIP_CHILDREN_DISABLED 
		water_mask.visible = false
		var suck_tween = create_tween()
		suck_tween.tween_property(self, "global_position", body.global_position, 0.25).set_ease(Tween.EASE_IN)
		suck_tween.parallel().tween_property(sprite, "scale", Vector2.ZERO, 0.25).set_ease(Tween.EASE_IN)
		
		await suck_tween.finished
		
		var reward = randi_range(min_gold, max_gold)
		PlayerData.add_gold(reward)
		
		queue_free()
