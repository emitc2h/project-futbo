class_name TrackTargetAction
extends BTAction

@export var offset: float

var drone: DroneV2


func _setup() -> void:
	drone = agent as DroneV2


func _tick(delta: float) -> Status:
	drone.track_target(offset, delta)
	return RUNNING
