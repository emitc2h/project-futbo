@tool
extends BTAction

@export var target_offset: float

var drone: Drone


func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	if agent.tracking_target:
		drone.stop_burst()
		drone.stop_thrust()
		var position_delta: float = drone.get_mode_position().x - drone.target.global_position.x
		var offset_sign: float = sign(position_delta)
		
		# Player is to the right of the drone and the drone faces the wrong way
		if position_delta < 0.0 and drone.direction == Enums.Direction.LEFT:
			drone.face_right()
			
		# Player is to the left of the drone
		if position_delta > 0.0 and drone.direction == Enums.Direction.RIGHT:
			drone.face_left()
			
		# Follow the player even when turning
		drone.move_toward_x_pos(drone.target.global_position.x + offset_sign * target_offset, delta)
		return RUNNING
	return FAILURE
