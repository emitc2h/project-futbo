class_name MainMenu
extends Node3D

signal new_game

@onready var soccer_ball_animation: AnimationPlayer = $"3DScene/SoccerBall/AnimationPlayer"

func _ready() -> void:
	soccer_ball_animation.play("enter_scene")


func _on_new_game_pressed() -> void:
	new_game.emit()


func _on_exit_pressed() -> void:
	get_tree().quit()
