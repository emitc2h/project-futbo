class_name PlayerAsset
extends Node3D

var animation: String:
	get = get_animation, set = set_animation
var flip_h: bool:
	get = get_flip_h, set = set_flip_h


func play(animation_name: String) -> void:
	pass


func get_animation() -> String:
	return ""


func set_animation(value: String) -> void:
	pass


func get_flip_h() -> bool:
	return false


func set_flip_h(value: bool) -> void:
	pass
