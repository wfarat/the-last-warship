extends Node2D
class_name EnemyCanon
@export var tier_animations: Array[SpriteFrames] 
@onready var animated_sprite = $AnimatedSprite2D
@export var bullet_scene: PackedScene 
@export var fire_rate: float = 0.5 
@export var damage: int = 20

# We "override" the blank function from the master script
func play_shoot_effects():
	animated_sprite.play("shoot")
	await animated_sprite.animation_finished
	animated_sprite.play("idle")
