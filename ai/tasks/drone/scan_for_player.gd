@tool
extends BTAction

func _tick(delta: float) -> Status:
	if agent.sees_player:
		return SUCCESS
	return RUNNING
