class_name CharacterGroundedStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

## Parameters
@export_group("Movement")
@export var run_speed: float = 3.0

## States Enum
enum State {IDLE = 0, MOVING= 1, MOVING_BUFFER = 2, JUMP = 3}
var state: State = State.IDLE

## State transition constants
const TRANS_TO_IDLE: String = "Grounded: to idle"
const TRANS_TO_MOVING: String = "Grounded: to moving"
const TRANS_TO_JUMP: String = "Grounded: to jump"

## Settable Parameters
var left_right_axis: float = 0.0


# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	state = State.IDLE


# moving state
#----------------------------------------
func _on_moving_state_entered() -> void:
	state = State.MOVING


# jump state
#----------------------------------------
func _on_jump_state_entered() -> void:
	state = State.JUMP
