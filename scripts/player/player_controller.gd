class_name PlayerController
extends Node

@export var character: CharacterBase
@export var idle_buffer_time: float = 0.07

var left_right_axis_is_zero_time_elapsed: float = 0.0

func _physics_process(delta: float) -> void:
	var left_right_axis: float = Input.get_axis("move_left", "move_right")
	
	if abs(left_right_axis) > 0.0:
		character.move(left_right_axis)
		left_right_axis_is_zero_time_elapsed = 0.0
	else:
		left_right_axis_is_zero_time_elapsed += delta

	if left_right_axis_is_zero_time_elapsed > idle_buffer_time:
		character.idle()
