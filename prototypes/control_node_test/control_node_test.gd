extends Node3D

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	$AnimationPlayer.play("test_blow_animation")
