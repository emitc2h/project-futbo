@tool
extends BTAction

func _tick(delta: float) -> Status:
	agent.stop_moving(delta)
	if abs(agent.left_right_axis) < 0.01:
		return FAILURE
	return RUNNING
