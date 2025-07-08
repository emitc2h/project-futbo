@tool
extends BTAction

var drone: Drone
var attack_initiated: bool


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	attack_initiated = false
	

func _tick(delta: float) -> Status:
	
	var position_delta: float = drone.get_mode_position().x - drone.target.global_position.x

	# destination is to the right of the drone and the drone faces the wrong way
	if position_delta < 0.0 and drone.direction == Enums.Direction.LEFT:
		drone.face_right()
			
	# destination is to the left of the drone
	if position_delta > 0.0 and drone.direction == Enums.Direction.RIGHT:
		drone.face_left()

	if not drone.in_turn_state:
		if not attack_initiated:
			drone.ram_attack()
			attack_initiated = true
		if drone.in_burst_state:
			drone.move_toward_target(delta)
	
	if drone.in_rigid_state:
		return SUCCESS
			
	return RUNNING
