@tool
class_name IsInTargetingStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DroneTargetingStates.State

func _generate_name() -> String:
	return "Targeting state expected to be " + DroneTargetingStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	print("expected: ", DroneTargetingStates.State.keys()[expected_state], " | actual: ", DroneTargetingStates.State.keys()[drone.targeting_states.state])
	if drone.targeting_states.state == expected_state:
		return SUCCESS
	return FAILURE
