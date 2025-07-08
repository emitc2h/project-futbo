@tool
class_name MoveTo
extends BTAction

@export var distance_when_to_stop: float
@export var initial_burst: bool = false
@export var use_thrust: bool = false
@export var move_away: bool = false

var arrived: bool
var has_burst_already: bool
var thrust_set: bool

var drone: Drone


func _generate_name() -> String:
	var burst: String = ""
	var action_name: String = "Move"
	var to_from: String = " to "
	if initial_burst:
		burst = "Burst then "
	if use_thrust:
		action_name = "Thrust"
	if move_away:
		to_from = " away from "
	
	return burst + action_name + to_from + _get_destination_name()


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	arrived = false
	has_burst_already = false
	thrust_set = false


func _tick(delta: float) -> Status:
	var position_delta: float = drone.get_mode_position().x - _get_destination_x()

	if move_away:
		if (abs(position_delta) > distance_when_to_stop):
			arrived = true
	else:
		if (abs(position_delta) < distance_when_to_stop):
			arrived = true
	
	if arrived:
		drone.stop_thrust()
		drone.stop_burst()
		drone.stop_moving(delta)
		if abs(drone.left_right_axis) < 0.01:
			return SUCCESS
		else:
			return RUNNING
	else:
		if move_away:
			# destination is to the right of the drone and the drone faces the wrong way
			if position_delta < 0.0 and drone.direction == Enums.Direction.RIGHT:
				drone.face_left()
			
			# destination is to the left of the drone
			if position_delta > 0.0 and drone.direction == Enums.Direction.LEFT:
				drone.face_right()
		else:
			# destination is to the right of the drone and the drone faces the wrong way
			if position_delta < 0.0 and drone.direction == Enums.Direction.LEFT:
				drone.face_right()
			
			# destination is to the left of the drone
			if position_delta > 0.0 and drone.direction == Enums.Direction.RIGHT:
				drone.face_left()
		
		# Only move once the drone is done turning
		if not drone.in_turn_state:
			var after_burst_state: Drone.AfterBurst = Drone.AfterBurst.OFF
			if (use_thrust and not thrust_set):
				thrust_set = true
				drone.thrust()
				after_burst_state = Drone.AfterBurst.THRUST
			if (initial_burst and not has_burst_already):
				has_burst_already = true
				drone.burst(1.0, after_burst_state)
			if move_away:
				drone.move_toward_x_pos(_get_destination_x(), delta, true)
			else:
				drone.move_toward_x_pos(_get_destination_x(), delta)
		return RUNNING


func _get_destination_name() -> String:
	return ""


func _get_destination_x() -> float:
	return 0.0
