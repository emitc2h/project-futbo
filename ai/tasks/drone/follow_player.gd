@tool
extends BTAction

@export var target_offset: float

func _tick(delta: float) -> Status:
	if agent.tracking_target:
		var current_offset: float = agent.get_mode_position().x - agent.target.global_position.x
		var offset_sign: float = sign(current_offset)
		
		# Player is to the left of the drone
		if current_offset > 0.0:
			agent.face_left()
		# Player is to the right of the drone
		else:
			agent.face_right()
		
		agent.move_toward_x_pos(agent.target.global_position.x + offset_sign * target_offset, delta)
		return RUNNING
	return FAILURE
