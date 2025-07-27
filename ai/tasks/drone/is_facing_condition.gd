@tool
class_name IsFacingCondition
extends BTCondition

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

var drone: Drone
var target_x: float

func _generate_name() -> String:
	var name: String = ""
	if away:
		name += "Is facing away from "
	else:
		name += "Is facing "
	
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
	## Select the target x value based on the provided subject
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
			target_x = drone.repr.worldRepresentation.get(world_repr_pos_x_name)


func _tick(delta: float) -> Status:
	if target_x > drone.char_node.global_position.x and\
		(drone.direction_faced_states.state == drone.direction_faced_states.State.FACE_RIGHT or\
		 drone.direction_faced_states.state == drone.direction_faced_states.State.TURN_RIGHT):
		return SUCCESS
	if target_x < drone.char_node.global_position.x and\
		(drone.direction_faced_states.state == drone.direction_faced_states.State.FACE_LEFT or\
		 drone.direction_faced_states.state == drone.direction_faced_states.State.TURN_LEFT):
		return SUCCESS
	return FAILURE
