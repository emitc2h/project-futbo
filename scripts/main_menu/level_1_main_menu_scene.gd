extends Node3D

@onready var soccer_ball_animation: AnimationPlayer = $"SoccerBall/AnimationPlayer"

func _ready() -> void:
	soccer_ball_animation.play("enter_scene")
