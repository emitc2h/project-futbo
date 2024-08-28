class_name PlayerBasicMovementController
extends Node2D

@export var player_basic_movement: PlayerBasicMovement

func _physics_process(delta: float) -> void:
	player_basic_movement.run(Input.get_axis("move_left", "move_right"))

	if Input.is_action_just_pressed("jump"):
		player_basic_movement.jump()
