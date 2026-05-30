extends Weapon
class_name StaticWeapon

@export var tier_texture: Array[CompressedTexture2D] 
@onready var sprite = $Sprite2D

# We override the function again, but with completely different logic!
func play_shoot_effects():
	# Make the sprite flash bright white for 0.1 seconds when it shoots
	var tween = create_tween()
	sprite.modulate = Color(2, 2, 2) # 2 is brighter than normal (HDR)
	tween.tween_property(sprite, "modulate", Color(1, 1, 1), 0.1)

func upgrade_sprite():
	sprite.texture = tier_texture[current_tier]
