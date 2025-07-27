@tool
class_name IsInEnginesStateCondition
extends BTCondition

var state_machine: DroneEnginesStates
var ignore: bool

@export var expected_state: DroneEnginesStates.State


func _generate_name() -> String:
	return "Engines state expected to be " + DroneEnginesStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.engines_states


func _tick(delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
