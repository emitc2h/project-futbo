@tool
class_name MoveToNodeAction
extends BTAction

@export var target_node: BBNode
@export var away: bool
@export var close_enough_distance: float
@export var far_enough_distance: float


var drone: DroneV2
var target_x: float
var arrived: bool


func _generate_name() -> String:
	return "Move to " + str(target_node)


func _setup() -> void:
	drone = agent as DroneV2


func _enter() -> void:
	target_x = target_node.get_value(scene_root, blackboard).global_position.x
	arrived = false


func _tick(delta: float) -> Status:
	var distance_to_target: float = target_x - drone.char_node.global_position.x

	if away:
		if (abs(distance_to_target) > far_enough_distance):
			arrived = true
	else:
		if (abs(distance_to_target) < close_enough_distance):
			arrived = true

	if arrived:
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
