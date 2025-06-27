@tool
extends BTAction

@export var destination_x: float
@export var distance_when_to_stop: float

func _generate_name() -> String:
	return "Move to global x = " + str(destination_x)


func _tick(delta: float) -> Status:
	var near: float = abs(agent.get_mode_position() - destination_x) < distance_when_to_stop
	if near:
		return SUCCESS
	else:
		agent.move_toward_x_pos(destination_x)
		return RUNNING
