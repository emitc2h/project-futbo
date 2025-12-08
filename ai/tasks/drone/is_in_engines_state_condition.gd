@tool
class_name IsInEnginesStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DroneEnginesStates.State

func _generate_name() -> String:
	return "Engines state expected to be " + DroneEnginesStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.engines_states.state == expected_state:
		return SUCCESS
	return FAILURE
