extends Node3D

@export var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player.play("enter_scene")
	await animation_player.animation_finished
	animation_player.play("camera_pan")
