class_name PlayerAssetSprite3D
extends PlayerAsset

@export var sprite: AnimatedSprite3D


func play(animation_name: String) -> void:
	sprite.play(animation_name)


func get_animation() -> String:
	return sprite.animation


func set_animation(value: String) -> void:
	sprite.animation = value


func get_flip_h() -> bool:
	return sprite.flip_h


func set_flip_h(value: bool) -> void:
	sprite.flip_h = value
