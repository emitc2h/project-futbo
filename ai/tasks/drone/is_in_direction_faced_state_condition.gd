@tool
class_name IsInDirectionFacedStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DroneDirectionFacedStates.State

func _generate_name() -> String:
	return "Direction Faced state expected to be " + DroneDirectionFacedStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.direction_faced_states.state == expected_state:
		return SUCCESS
	return FAILURE
