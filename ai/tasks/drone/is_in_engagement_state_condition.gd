@tool
class_name IsInEngagementStateCondition
extends BTCondition

var state_machine: DroneEngagementModeStates
var ignore: bool

@export var expected_state: DroneEngagementModeStates.State


func _generate_name() -> String:
	return "Engagement state expected to be " + DroneEngagementModeStates.State.keys()[expected_state]


func _setup() -> void:
	var drone: Drone = agent as Drone
	state_machine = drone.engagement_mode_states


func _tick(delta: float) -> Status:
	if ignore:
		return SUCCESS
	if state_machine.state == expected_state:
		return SUCCESS
	return FAILURE
