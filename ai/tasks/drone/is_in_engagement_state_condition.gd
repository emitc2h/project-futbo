@tool
class_name IsInEngagementStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DroneEngagementModeStates.State

func _generate_name() -> String:
	return "Engagement state expected to be " + DroneEngagementModeStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.engagement_mode_states.state == expected_state:
		return SUCCESS
	return FAILURE
