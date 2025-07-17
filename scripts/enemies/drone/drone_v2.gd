class_name DroneV2
extends Node3D

@onready var sc: StateChart = $State

## state machines
@onready var physics_mode_states: DronePhysicsModeStates = $"State/Root/Function/Physics Mode States"
@onready var direction_faced_states: DroneDirectionFacedStates = $"State/Root/Function/char/Direction Faced/Direction Faced States"
@onready var engagement_mode_states: DroneEngagementModeStates = $"State/Root/Function/char/Engagement Mode/Engagement Mode States"
@onready var engines_states: DroneEnginesStates = $"State/Root/Function/char/Engagement Mode/open - Engines/Engines States"

## Useful nodes to grab
@onready var char_node: CharacterBody3D = $CharNode

## Physics Controls
## ---------------------------------------
func become_rigid() -> void:
	sc.send_event(physics_mode_states.TRANS_CHAR_TO_RIGID)


func become_char() -> void:
	sc.send_event(physics_mode_states.TRANS_RIGID_TO_CHAR)


func become_ragdoll() -> void:
	sc.send_event(physics_mode_states.TRANS_CHAR_TO_RAGDOLL)


## Direction Controls
## ---------------------------------------
signal face_right_finished(id: int)

func face_right(id: int = 0) -> void:
	if not direction_faced_states.state == direction_faced_states.State.FACE_RIGHT:
		sc.send_event(direction_faced_states.TRANS_FACE_LEFT_TO_TURN_RIGHT)
		sc.send_event(direction_faced_states.TRANS_TURN_LEFT_TO_TURN_RIGHT)
		await direction_faced_states.is_now_facing_right
	face_right_finished.emit(id)


signal face_left_finished(id: int)

func face_left(id: int = 0) -> void:
	if not direction_faced_states.state == direction_faced_states.State.FACE_LEFT:
		sc.send_event(direction_faced_states.TRANS_FACE_RIGHT_TO_TURN_LEFT)
		sc.send_event(direction_faced_states.TRANS_TURN_RIGHT_TO_TURN_LEFT)
		await direction_faced_states.is_now_facing_left
	face_left_finished.emit(id)


func face_toward(x: float, id: int = 0) -> void:
	## If x is to the right of the drone, drone should face right
	if x > char_node.global_position.x:
		face_right(id)
	else:
		face_left(id)


## Movement Controls
## ---------------------------------------
func move_toward_x_pos(target_x: float, delta: float, away: bool = false) -> void:
	var direction: float = 1.0
	if away:
		direction = -1.0
	var target_value: float = direction * (target_x - char_node.global_position.x) / max(abs(target_x - char_node.global_position.x), 0.5)
	physics_mode_states.left_right_axis = lerp(physics_mode_states.left_right_axis, target_value, 20.0 * delta)


func stop_moving(delta: float) -> void:
	physics_mode_states.left_right_axis = lerp(physics_mode_states.left_right_axis, 0.0, 10.0 * delta)


## Engine Controls
## ---------------------------------------
func thrust() -> void:
	sc.send_event(engines_states.TRANS_OFF_TO_THRUST)
	sc.send_event(engines_states.TRANS_BURST_TO_THRUST)


func stop_thrust() -> void:
	sc.send_event(engines_states.TRANS_THRUST_TO_OFF)
