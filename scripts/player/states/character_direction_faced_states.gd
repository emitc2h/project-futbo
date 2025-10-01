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


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	state = State.FACE_LEFT
	mode = Mode.FACING


# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	state = State.FACE_RIGHT
	mode = Mode.FACING


# turn left state
#----------------------------------------
func _on_turn_left_state_entered() -> void:
	state = State.TURN_LEFT
	mode = Mode.TURNING


# turn right state
#----------------------------------------
func _on_turn_right_state_entered() -> void:
	state = State.TURN_RIGHT
	mode = Mode.TURNING
