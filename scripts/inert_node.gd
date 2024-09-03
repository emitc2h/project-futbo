class_name InertNode
extends RigidBody2D

var do_set_transform_and_velocity: bool = false
var transform_to_set: Transform2D
var velocity_to_set: Vector2

var do_set_impulse: bool = false
var impulse_to_set: Vector2


func set_transform_and_velocity(transform: Transform2D, velocity: Vector2) -> void:
	do_set_transform_and_velocity = true
	transform_to_set = transform
	velocity_to_set = velocity


func set_impulse(impulse: Vector2) -> void:
	do_set_impulse = true
	impulse_to_set = impulse


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if do_set_transform_and_velocity:
		state.transform = transform_to_set
		state.linear_velocity = velocity_to_set
		do_set_transform_and_velocity = false
	
	if do_set_impulse:
		state.apply_central_impulse(impulse_to_set)
		do_set_impulse = false
