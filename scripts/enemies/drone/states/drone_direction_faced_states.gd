class_name DroneDirectionFacedStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart

## States Enum
enum State {FACE_RIGHT = 0, FACE_LEFT = 1, TURN_RIGHT = 2, TURN_LEFT = 3}
var state: State = State.FACE_RIGHT
var direction: Enums.Direction = Enums.Direction.RIGHT

enum Mode {FACING = 0, TURNING = 1}
var mode: Mode = Mode.FACING

## State transition constants
const TRANS_TO_TURN_LEFT: String = "Direction Faced: to turn left"
const TRANS_TO_TURN_RIGHT: String = "Direction Faced: to turn right"
const TRANS_TO_FACE_RIGHT: String = "Direction Faced: to face right"
const TRANS_TO_FACE_LEFT: String = "Direction Faced: to face left"


## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = drone.get_node("CharNode")

## Internal constants
const FACE_RIGHT_Y_ROT = Vector3(0.0, PI/2, 0.0)
const FACE_LEFT_Y_ROT = Vector3(0.0, -PI/2, 0.0)

## Internal variables
var tween: Tween

## Signals
signal is_now_facing_right
signal is_now_facing_left


func _rotate_toward(vector: Vector3) -> void:
	var target_orientation: Quaternion = Quaternion.from_euler(vector)
	var current_orientation: Quaternion = Quaternion.from_euler(char_node.rotation)
	var new_orientation: Quaternion = current_orientation.slerp(target_orientation, 0.15)
	char_node.rotation = new_orientation.get_euler()


# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	state = State.FACE_RIGHT
	mode = Mode.FACING
	is_now_facing_right.emit()


func _on_face_right_state_physics_processing(delta: float) -> void:
	self._rotate_toward(FACE_RIGHT_Y_ROT)


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	state = State.FACE_LEFT
	mode = Mode.FACING
	is_now_facing_left.emit()


func _on_face_left_state_physics_processing(delta: float) -> void:
	self._rotate_toward(FACE_LEFT_Y_ROT)


# turn right state
#----------------------------------------
func _on_turn_right_state_entered() -> void:
	state = State.TURN_RIGHT
	direction = Enums.Direction.RIGHT
	mode = Mode.TURNING
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(char_node, "rotation", Vector3.ZERO, 0.375)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(char_node.rotation)
	tween.tween_property(char_node, "rotation", FACE_RIGHT_Y_ROT, 0.75)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3.ZERO)
		
	await tween.finished
	sc.send_event(TRANS_TO_FACE_RIGHT)


# turn left state
#----------------------------------------
func _on_turn_left_state_entered() -> void:
	state = State.TURN_LEFT
	direction = Enums.Direction.LEFT
	mode = Mode.TURNING
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(char_node, "rotation", Vector3.ZERO, 0.375)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(char_node.rotation)
	tween.tween_property(char_node, "rotation", FACE_LEFT_Y_ROT, 0.75)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3.ZERO)
		
	await tween.finished
	sc.send_event(TRANS_TO_FACE_LEFT)
