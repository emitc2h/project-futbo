class_name StopMovingAction
extends BTAction

var drone: Drone

func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	if drone.physics_mode_states.left_right_axis < 0.01:
		drone.physics_mode_states.left_right_axis = 0.0
		return SUCCESS
	drone.stop_moving(delta)
	return RUNNING
