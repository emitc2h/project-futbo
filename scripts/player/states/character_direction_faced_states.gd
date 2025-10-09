class_name CharacterDirectionFacedStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

## States Enum
enum State {FACE_RIGHT = 0, FACE_LEFT = 1}
var state: State = State.FACE_LEFT

## State transition constants
const TRANS_TO_FACE_LEFT: String = "Direction Faced: to face left"
const TRANS_TO_FACE_RIGHT: String = "Direction Faced: to face right"

## Direction Constants
var LEFT_ROTATION: Quaternion = Quaternion.from_euler(Vector3(0.0, PI, 0.0))
var RIGHT_ROTATION: Quaternion = Quaternion.from_euler(Vector3(0.0, 0.0, 0.0))

## rotation tween
var rotation_tween: Tween


func _ready() -> void:
	cement_rotation()


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	state = State.FACE_LEFT


# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	state = State.FACE_RIGHT


#=======================================================
# CONTROLS
#=======================================================
func face_direction_based_on_axis(left_right_axis: float) -> void:
	if state == State.FACE_RIGHT and left_right_axis < 0.0:
		sc.send_event(TRANS_TO_FACE_LEFT)
		_tween_rotation(LEFT_ROTATION)
	
	if state == State.FACE_LEFT and left_right_axis > 0.0:
		sc.send_event(TRANS_TO_FACE_RIGHT)
		_tween_rotation(RIGHT_ROTATION)


func switch_direction() -> void:
	if state == State.FACE_RIGHT:
		sc.send_event(TRANS_TO_FACE_LEFT)
	else:
		sc.send_event(TRANS_TO_FACE_RIGHT)


func cement_rotation() -> void:
	if state == State.FACE_RIGHT:
		_tween_rotation(RIGHT_ROTATION)
	else:
		_tween_rotation(LEFT_ROTATION)


func turn_sign() -> float:
	if state == State.FACE_RIGHT:
		return -1.0
	else:
		return 1.0


#=======================================================
# UTILITIES
#=======================================================
func _tween_rotation(target_rotation: Quaternion) -> void:
	if rotation_tween:
		rotation_tween.kill()
	rotation_tween = get_tree().create_tween()
	rotation_tween.tween_property(character, "quaternion", target_rotation, 0.3)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
	await rotation_tween.finished


func faced_direction_is_consistent_with_axis(left_right_axis: float) -> bool:
	if state == State.FACE_RIGHT and left_right_axis < 0.0:
		return false
	
	if state == State.FACE_LEFT and left_right_axis > 0.0:
		return false
	
	return true
