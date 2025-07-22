class_name TrackTargetAction
extends BTAction

@export_group("Parameters")
@export var offset: float

var drone: Drone


func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	drone.track_target(offset, delta)
	return RUNNING
