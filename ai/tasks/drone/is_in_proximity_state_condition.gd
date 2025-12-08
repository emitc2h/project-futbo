@tool
class_name IsInProximityStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DroneProximityStates.State

func _generate_name() -> String:
	return "Proximity state expected to be " + DroneProximityStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.proximity_states.state == expected_state:
		return SUCCESS
	return FAILURE
