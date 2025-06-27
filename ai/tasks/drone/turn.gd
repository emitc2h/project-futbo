@tool
extends BTAction

@export var direction: Enums.Direction

func _generate_name() -> String:
	if direction == Enums.Direction.LEFT:
		return "Turn Left"
	if direction == Enums.Direction.RIGHT:
		return "Turn Right"
	return "Turn ?"


func _enter() -> void:
	if direction == Enums.Direction.LEFT:
		agent.face_left()
	if direction == Enums.Direction.RIGHT:
		agent.face_right()


func _tick(delta: float) -> Status:
	if not agent.in_turn_state:
		return SUCCESS
	else:
		agent.stop_moving(delta)
		return RUNNING
