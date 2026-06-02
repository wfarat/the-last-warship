extends Weapon # We inherit everything from weapon.gd!
class_name Enemy
@export var tier_animations: Array[SpriteFrames] 
@onready var animated_sprite = $AnimatedSprite2D

# We "override" the blank function from the master script
func play_shoot_effects():
	animated_sprite.play("shoot")
	await animated_sprite.animation_finished
	animated_sprite.play("idle")

func upgrade_sprite():
	animated_sprite.sprite_frames = tier_animations[current_tier]
