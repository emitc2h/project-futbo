@tool
class_name MoveToNodeAction
extends BTAction

const CUSTOM_POS_X: String = "custom x position"
const CUSTOM_NODE: String = "custom node"
const TARGET_NODE: String = "target node"
const PLAYER_REPR: String = "player representation"
const WORLD_REPR_POS_X: String = "world representation x position"
const CONTROL_NODE_REPR: String = "control node representation"

@export_group("Subject")
@export var custom_node: BBNode
@export var world_repr_pos_x_name: String
@export_enum(CUSTOM_NODE, TARGET_NODE, PLAYER_REPR, CONTROL_NODE_REPR, WORLD_REPR_POS_X) var target_type: String

@export_group("Parameters")
@export var away: bool
@export var close_enough_distance: float
@export var far_enough_distance: float

@export_group("Engines")
@export var use_burst: bool
@export var use_thrust: bool


var drone: Drone
var target_x: float
var arrived: bool


func _generate_name() -> String:
	var name: String = ""
	if away:
		name += "Move away from "
	else:
		name += "Move to "

	match(target_type):
		CUSTOM_NODE:
			name += str(custom_node)
		WORLD_REPR_POS_X:
			name += target_type + ": " + world_repr_pos_x_name
		_:
			name += target_type

	return name


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	match(target_type):
		CUSTOM_NODE:
			target_x = custom_node.get_value(scene_root, blackboard).global_position.x
		TARGET_NODE:
			target_x = drone.targeting_states.target.global_position.x
		PLAYER_REPR:
			target_x = drone.repr.playerRepresentation.last_known_player_pos_x
		CONTROL_NODE_REPR:
			target_x = drone.repr.controlNodeRepresentation.last_known_control_node_pos_x
		WORLD_REPR_POS_X:
			assert(world_repr_pos_x_name in drone.repr.worldRepresentation)
			target_x = drone.repr.worldRepresentation.get(world_repr_pos_x_name)

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
