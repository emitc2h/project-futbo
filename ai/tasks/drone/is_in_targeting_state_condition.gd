@tool
class_name IsInTargetingStateCondition
extends BTCondition

var state_machine: DroneTargetingStates
var ignore: bool

@export var expected_state: DroneTargetingStates.State


func _generate_name() -> String:
	return "Targeting state expected to be " + DroneTargetingStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.targeting_states


func _tick(_delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
