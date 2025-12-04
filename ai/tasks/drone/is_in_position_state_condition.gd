@tool
class_name IsInPositionStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DronePositionStates.State

func _generate_name() -> String:
	return "Position state expected to be " + DronePositionStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.position_states.state == expected_state:
		return SUCCESS
	return FAILURE
