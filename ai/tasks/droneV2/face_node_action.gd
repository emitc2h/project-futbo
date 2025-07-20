@tool
class_name FaceNodeAction
extends BTAction

@export var target_node: BBNode
@export var away: bool
@export var use_target: bool

var drone: DroneV2
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
	if use_target:
		name += "target"
	else:
		name += str(target_node)
	return name


func _setup() -> void:
	drone = agent as DroneV2
	drone.face_left_finished.connect(_face_action_finished)
	drone.face_right_finished.connect(_face_action_finished)


func _enter() -> void:
	signal_id = rng.randi()
	done = false
	if use_target:
		target_x = drone.targeting_states.target.global_position.x
	else:
		target_x = target_node.get_value(scene_root, blackboard).global_position.x
	if away:
		drone.face_away(target_x, signal_id)
	else:
		drone.face_toward(target_x, signal_id)


func _tick(delta: float) -> Status:
	if done:
		return SUCCESS
	return RUNNING


func _face_action_finished(id: int) -> void:
	if signal_id == id:
		done = true
