@tool
class_name IsInProximityStateCondition
extends BTCondition

var state_machine: DroneProximityStates
var ignore: bool

@export var expected_state: DroneProximityStates.State


func _generate_name() -> String:
	return "Proximity state expected to be " + DroneProximityStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.proximity_states


func _tick(delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
