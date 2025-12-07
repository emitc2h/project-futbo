class_name IsOutsidePatrolMarkersCondition
extends BTCondition

@export var tolerance: float = 0.0

var drone: Drone


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.position_states.is_between_patrol_markers(tolerance):
		return FAILURE
	return SUCCESS
