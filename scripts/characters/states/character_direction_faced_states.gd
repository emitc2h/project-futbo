class_name CharacterDirectionFacedStates
extends CharacterStatesAbstractBase

## States Enum
enum State {FACE_RIGHT = 0, FACE_LEFT = 1}
var state: State = State.FACE_LEFT

## State transition constants
const TRANS_TO_FACE_LEFT: String = "Direction Faced: to face left"
const TRANS_TO_FACE_RIGHT: String = "Direction Faced: to face right"

## Direction Constants
var LEFT_ROTATION: Quaternion = Quaternion.from_euler(Vector3(0.0, PI, 0.0))
var RIGHT_ROTATION: Quaternion = Quaternion.from_euler(Vector3(0.0, 0.0, 0.0))

var left_rotation: Quaternion = LEFT_ROTATION
var right_rotation: Quaternion = RIGHT_ROTATION

## rotation tween
var rotation_tween: Tween

## Settable Parameters
var locked: bool


func _ready() -> void:
	cement_rotation()


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	state = State.FACE_LEFT
	print("face left entered")
	if character.is_player:
		Signals.player_moved.emit()
		Signals.facing_left.emit()


# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	state = State.FACE_RIGHT
	print("face right entered")
	if character.is_player:
		Signals.player_moved.emit()
		Signals.facing_right.emit()


#=======================================================
# CONTROLS
#=======================================================
func face_direction_based_on_axis(left_right_axis: float) -> void:
	if locked: return
	
	if state == State.FACE_RIGHT and left_right_axis < 0.0:
		sc.send_event(TRANS_TO_FACE_LEFT)
		_tween_rotation(left_rotation)
	
	if state == State.FACE_LEFT and left_right_axis > 0.0:
		sc.send_event(TRANS_TO_FACE_RIGHT)
		_tween_rotation(right_rotation)


func switch_direction() -> void:
	if locked: return
	
	if state == State.FACE_RIGHT:
		sc.send_event(TRANS_TO_FACE_LEFT)
	else:
		sc.send_event(TRANS_TO_FACE_RIGHT)


func face_left() -> void:
	sc.send_event(TRANS_TO_FACE_LEFT)
	cement_rotation(1.0)


func face_right() -> void:
	sc.send_event(TRANS_TO_FACE_RIGHT)
	cement_rotation(1.0)


func cement_rotation(duration: float = 0.3) -> void:
	if state == State.FACE_RIGHT:
		_tween_rotation(right_rotation, duration)
	else:
		_tween_rotation(left_rotation, duration)


func apply_rotation() -> void:
	if state == State.FACE_RIGHT:
		character.quaternion = right_rotation
	else:
		character.quaternion = left_rotation


func turn_sign() -> float:
	if state == State.FACE_RIGHT:
		return -1.0
	else:
		return 1.0


func face_sign() -> float:
	if state == State.FACE_RIGHT:
		return 1.0
	else:
		return -1.0


func move_sign(left_right_axis: float) -> float:
	if locked:
		if state == State.FACE_RIGHT:
			return 1.0
		else:
			return -1.0
	return sign(left_right_axis)


func define_left_right_axis(y_rot: float) -> void:
	right_rotation = Quaternion.from_euler(Vector3.UP * y_rot)
	left_rotation = Quaternion.from_euler(Vector3.UP * (y_rot + PI))


func reset_left_right_axis() -> void:
	left_rotation = LEFT_ROTATION
	right_rotation = RIGHT_ROTATION


func lock_direction_faced() -> void:
	locked = true


func unlock_direction_faced(left_right_axis: float) -> void:
	locked = false
	## Makes sure the character doesn't turn when releasing the dribble button if running backward
	face_direction_based_on_axis(left_right_axis)


#=======================================================
# UTILITIES
#=======================================================
func _tween_rotation(target_rotation: Quaternion, duration: float = 0.3) -> void:
	if rotation_tween:
		rotation_tween.kill()
	rotation_tween = get_tree().create_tween()
	rotation_tween.tween_property(character, "quaternion", target_rotation, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CIRC)
	await rotation_tween.finished


func faced_direction_is_consistent_with_axis(left_right_axis: float) -> bool:
	if locked:
		return true
	if state == State.FACE_RIGHT and left_right_axis < 0.0:
		return false
	if state == State.FACE_LEFT and left_right_axis > 0.0:
		return false
	return true

func running_backward(left_right_axis: float) -> bool:
	if locked:
		if left_right_axis < 0.0 and state == State.FACE_RIGHT:
			return true
		if left_right_axis > 0.0 and state == State.FACE_LEFT:
			return true
	return false
