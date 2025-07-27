@tool
class_name IsInPhysicsStateCondition
extends BTCondition

var state_machine: DronePhysicsModeStates
var ignore: bool

@export var expected_state: DronePhysicsModeStates.State


func _generate_name() -> String:
	return "Physics state expected to be " + DronePhysicsModeStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.physics_mode_states


func _tick(delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
