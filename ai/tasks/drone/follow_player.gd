@tool
extends BTAction

@export var target_offset: float

func _tick(delta: float) -> Status:
	if agent.tracking_target:
		var position_delta: float = agent.get_mode_position().x - agent.target.global_position.x
		var offset_sign: float = sign(position_delta)
		
		# Player is to the right of the drone and the drone faces the wrong way
		if position_delta < 0.0 and agent.direction == Enums.Direction.LEFT:
			agent.face_right()
			
		# Player is to the left of the drone
		if position_delta > 0.0 and agent.direction == Enums.Direction.RIGHT:
			agent.face_left()
			
		# Follow the player even when turning
		agent.move_toward_x_pos(agent.target.global_position.x + offset_sign * target_offset, delta)
		return RUNNING
	return FAILURE
