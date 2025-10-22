class_name InertNode
extends RigidBody3D

var do_set_transform_and_velocity: bool = false
var transform_to_set: Transform3D
var velocity_to_set: Vector3
var max_speed: float
var velocity_from_previous_frame: Vector3

var do_set_impulse: bool = false
var impulse_to_set: Vector3


func sleep() -> void:
	self.set_freeze_enabled(true)
	self.can_sleep = true
	self.sleeping = true


func wake_up() -> void:
	self.set_freeze_enabled(false)
	self.can_sleep = false
	self.sleeping = false


func set_transform_and_velocity(new_transform: Transform3D, new_velocity: Vector3) -> void:
	do_set_transform_and_velocity = true
	transform_to_set = new_transform
	velocity_to_set = new_velocity


func set_impulse(impulse: Vector3) -> void:
	# Make sure the node wakes up when an impulse is applied, otherwise
	# _integrate_forces won't be called
	self.sleeping = false
	do_set_impulse = true
	impulse_to_set = impulse


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if do_set_transform_and_velocity:
		state.transform = transform_to_set
		state.linear_velocity = velocity_to_set
		do_set_transform_and_velocity = false
	
	if do_set_impulse:
		state.apply_central_impulse(impulse_to_set)
		do_set_impulse = false


func _physics_process(_delta: float) -> void:
	velocity_from_previous_frame = self.linear_velocity
