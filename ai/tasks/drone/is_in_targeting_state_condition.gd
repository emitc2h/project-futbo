@tool
class_name IsInTargetingStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DroneTargetingStates.State
@export var is_not: bool = false

func _generate_name() -> String:
	var output_str: String = "Targeting state expected "
	if is_not:
		output_str += "not "
	output_str += "to be " + DroneTargetingStates.State.keys()[expected_state]
	return output_str


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if (drone.targeting_states.state == expected_state) != is_not:
		return SUCCESS
	return FAILURE
