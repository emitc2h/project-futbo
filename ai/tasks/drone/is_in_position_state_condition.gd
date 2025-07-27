@tool
class_name IsInPositionStateCondition
extends BTCondition

var state_machine: DronePositionStates
var ignore: bool

@export var expected_state: DronePositionStates.State


func _generate_name() -> String:
	return "Position state expected to be " + DronePositionStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.position_states


func _tick(delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
