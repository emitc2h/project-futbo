class_name CharacterDirectionFacedStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

## States Enum
enum State {FACE_RIGHT = 0, FACE_LEFT = 1, TURN_RIGHT = 2, TURN_LEFT = 3}
var state: State = State.FACE_RIGHT

enum Mode {FACING = 0, TURNING = 1}
var mode: Mode = Mode.FACING

## State transition constants
const TRANS_TO_FACE_LEFT: String = "Direction Faced: to face left"
const TRANS_TO_FACE_RIGHT: String = "Direction Faced: to face right"
const TRANS_TO_TURN_LEFT: String = "Direction Faced: to turn left"
const TRANS_TO_TURN_RIGHT: String = "Direction Faced: to turn right"

## Direction Constants
const LEFT_ROTATION: Vector3 = Vector3(0.0, -90.0, 0.0)
const RIGHT_ROTATION: Vector3 = Vector3(0.0, 90.0, 0.0)

## rotation tween
var rotation_tween: Tween

# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	state = State.FACE_LEFT
	mode = Mode.FACING
	
	## Set the rotation
	if not (rotation_tween and rotation_tween.is_running()):
		character.rotation_degrees = LEFT_ROTATION


func _on_face_right_to_face_left_taken() -> void:
	_tween_rotation(LEFT_ROTATION)


func _on_turn_left_to_face_left_taken() -> void:
	_tween_rotation(LEFT_ROTATION)

# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	state = State.FACE_RIGHT
	mode = Mode.FACING
	
	## Set the rotation
	if not (rotation_tween and rotation_tween.is_running()):
		character.rotation_degrees = RIGHT_ROTATION


func _on_face_left_to_face_right_taken() -> void:
	_tween_rotation(RIGHT_ROTATION)


func _on_turn_right_to_face_right_taken() -> void:
	_tween_rotation(RIGHT_ROTATION)


# turn left state
#----------------------------------------
func _on_turn_left_state_entered() -> void:
	state = State.TURN_LEFT
	mode = Mode.TURNING
	
	await character.asset.turn()
	sc.send_event(TRANS_TO_FACE_LEFT)


func _on_turn_left_state_physics_processing(_delta: float) -> void:
	character.quaternion = character.quaternion * character.asset.root_motion_rotation


# turn right state
#----------------------------------------
func _on_turn_right_state_entered() -> void:
	state = State.TURN_RIGHT
	mode = Mode.TURNING
	
	await character.asset.turn()
	sc.send_event(TRANS_TO_FACE_RIGHT)


func _on_turn_right_state_physics_processing(_delta: float) -> void:
	character.quaternion = character.quaternion * character.asset.root_motion_rotation



#=======================================================
# CONTROLS
#=======================================================
func face_direction_based_on_axis(left_right_axis: float) -> void:
	if state == State.FACE_RIGHT and left_right_axis < 0.0:
		sc.send_event(TRANS_TO_FACE_LEFT)
	
	if state == State.FACE_LEFT and left_right_axis > 0.0:
		sc.send_event(TRANS_TO_FACE_RIGHT)


func turn_based_on_axis(left_right_axis: float) -> void:
	if state == State.FACE_RIGHT and left_right_axis < 0.0:
		sc.send_event(TRANS_TO_TURN_LEFT)
	
	if state == State.FACE_LEFT and left_right_axis > 0.0:
		sc.send_event(TRANS_TO_TURN_RIGHT)


func direction_sign(left_right_axis: float) -> float:
	if mode == Mode.FACING:
		return sign(left_right_axis)
	else:
		match(state):
			State.TURN_RIGHT:
				return -1.0
			State.TURN_LEFT:
				return 1.0
			_:
				return 1.0


#=======================================================
# UTILITIES
#=======================================================
func _tween_rotation(target_rotation: Vector3) -> void:
	if rotation_tween:
		rotation_tween.kill()
	rotation_tween = get_tree().create_tween()
	rotation_tween.tween_property(character, "rotation_degrees", target_rotation, 0.3)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
	await rotation_tween.finished
