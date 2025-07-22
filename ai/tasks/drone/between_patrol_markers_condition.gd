class_name BetweenPatrolMarkersCondition
extends BTCondition

var drone: Drone


func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	if drone.position_states.is_between_patrol_markers():
		return SUCCESS
	return FAILURE
