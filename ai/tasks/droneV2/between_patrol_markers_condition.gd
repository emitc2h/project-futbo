class_name BetweenPatrolMarkersCondition
extends BTCondition

var drone: DroneV2


func _setup() -> void:
	drone = agent as DroneV2


func _tick(delta: float) -> Status:
	if drone.position_states.is_between_patrol_markers():
		return SUCCESS
	return FAILURE
