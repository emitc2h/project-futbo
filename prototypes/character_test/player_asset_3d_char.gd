class_name PlayerAsset3DChar
extends PlayerAsset

@export var character_asset: CharacterAsset


func play(animation_name: String) -> void:
	character_asset.play(animation_name)


func get_animation() -> String:
	return character_asset.animation


func set_animation(value: String) -> void:
	character_asset.animation = value


func get_flip_h() -> bool:
	return character_asset.flip_h


func set_flip_h(value: bool) -> void:
	character_asset.flip_h = value
