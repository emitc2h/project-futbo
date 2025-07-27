@tool
class_name IsInDirectionFacedStateCondition
extends BTCondition

var state_machine: DroneDirectionFacedStates
var ignore: bool

@export var expected_state: DroneDirectionFacedStates.State


func _generate_name() -> String:
	return "Direction Faced state expected to be " + DroneDirectionFacedStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.direction_faced_states


func _tick(delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
