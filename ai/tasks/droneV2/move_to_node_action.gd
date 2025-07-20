@tool
class_name MoveToNodeAction
extends BTAction

@export var target_node: BBNode
@export var away: bool
@export var use_target: bool
@export var use_burst: bool
@export var use_thrust: bool
@export var close_enough_distance: float
@export var far_enough_distance: float


var drone: DroneV2
var target_x: float
var arrived: bool


func _generate_name() -> String:
	var name: String = ""
	if away:
		name += "Move away from "
	else:
		name += "Move to "
	if use_target:
		name += "target"
	else:
		name += str(target_node)
	return name


func _setup() -> void:
	drone = agent as DroneV2


func _enter() -> void:
	if use_target:
		target_x = drone.targeting_states.target.global_position.x
	else:
		target_x = target_node.get_value(scene_root, blackboard).global_position.x
	arrived = false
	_check_arrived()
	if not arrived:
		if use_thrust:
			drone.thrust()
		if use_burst:
			drone.burst()


func _tick(delta: float) -> Status:
	_check_arrived()
	if arrived:
		drone.stop_engines()
		drone.stop_moving(delta)
		if abs(drone.physics_mode_states.left_right_axis) < 0.01:
			return SUCCESS
		else:
			return RUNNING
	
	if away:
		drone.move_toward_x_pos(target_x, delta, true)
	else:
		drone.move_toward_x_pos(target_x, delta)
	return RUNNING


func _check_arrived() -> void:
	var distance_to_target: float = target_x - drone.char_node.global_position.x
	
	if away:
		if (abs(distance_to_target) > far_enough_distance):
			arrived = true
	else:
		if (abs(distance_to_target) < close_enough_distance):
			arrived = true
