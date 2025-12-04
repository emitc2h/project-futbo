@tool
class_name FaceNodeAction
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
@export var async: bool

var drone: Drone
var target_x: float
var done: bool
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _generate_name() -> String:
	var name: String = ""
	if away:
		name += "Face away from "
	else:
		name += "Face "
	
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
	drone.face_left_finished.connect(_face_action_finished)
	drone.face_right_finished.connect(_face_action_finished)


func _enter() -> void:
	signal_id = rng.randi()
	done = false
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
	
	## Select which direction to face w.r.t. the subject
	if away:
		drone.face_away(target_x, signal_id)
	else:
		drone.face_toward(target_x, signal_id)
	
	## If async, do not wait for the turn action to finish to declare SUCCESS and move on
	if async:
		done = true


func _tick(_delta: float) -> Status:
	if done:
		return SUCCESS
	return RUNNING


func _face_action_finished(id: int) -> void:
	if signal_id == id:
		done = true
