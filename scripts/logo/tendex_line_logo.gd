extends Node3D

@export var anim_player: AnimationPlayer

func _ready() -> void:
	anim_player.play("open up", -1, 1.5)
