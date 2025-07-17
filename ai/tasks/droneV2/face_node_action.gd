@tool
class_name FaceNodeAction
extends BTAction

@export var target_node: BBNode

var drone: DroneV2
var target_x: float
var done: bool
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _generate_name() -> String:
	return "Face " + str(target_node)


func _setup() -> void:
	drone = agent as DroneV2
	drone.face_left_finished.connect(_face_action_finished)
	drone.face_right_finished.connect(_face_action_finished)


func _enter() -> void:
	signal_id = rng.randi()
	done = false
	target_x = target_node.get_value(scene_root, blackboard).global_position.x
	drone.face_toward(target_x, signal_id)


func _tick(delta: float) -> Status:
	if done:
		return SUCCESS
	return RUNNING


func _face_action_finished(id: int) -> void:
	if signal_id == id:
		done = true
