@tool
extends BTAction

@export var target_offset: float
@export var time_limit: float = 0.0

var drone: Drone
var time_elapsed: float


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	time_elapsed = 0.0


func _tick(delta: float) -> Status:
	time_elapsed += delta
	if time_limit != 0.0 and time_elapsed > time_limit:
		return SUCCESS
	
	if agent.tracking_target:
		drone.stop_burst()
		drone.stop_thrust()
		var position_delta: float = drone.face_target()
		var offset_sign: float = sign(position_delta)
			
		# Follow the player even when turning
		drone.move_toward_x_pos(drone.target.global_position.x + offset_sign * target_offset, delta)
		return RUNNING
	
	return FAILURE
