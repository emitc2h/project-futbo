class_name DroneV2
extends Node3D

@onready var sc: StateChart = $State

## state machines
@export_group("State Machines")
@export_subgroup("Function State Machines")
@export var physics_mode_states: DronePhysicsModeStates
@export var direction_faced_states: DroneDirectionFacedStates
@export var engagement_mode_states: DroneEngagementModeStates
@export var engines_states: DroneEnginesStates

@export_subgroup("Monitoring State Machines")
@export var targeting_states: DroneTargetingStates
@export var position_states: DronePositionStates

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


func face_away(x: float, id: int = 0) -> void:
	## If x is to the right of the drone, drone should face left
	if x > char_node.global_position.x:
		face_left(id)
	else:
		face_right(id)


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


func track_target(offset: float, delta: float) -> void:
	var target_x: float = targeting_states.target.global_position.x
	face_toward(target_x)
	var offset_sign: float = sign(char_node.global_position.x - target_x)
	move_toward_x_pos(target_x + offset_sign * offset, delta)


## Engagement Controls
## ---------------------------------------
signal open_finished(id: int)

func open(id: int = 0) -> void:
	sc.send_event(engagement_mode_states.TRANS_CLOSED_TO_OPENING)
	sc.send_event(engagement_mode_states.TRANS_CLOSING_TO_OPENING)
	await engagement_mode_states.opening_finished
	open_finished.emit(id)


signal close_finished(id: int)

func close(id: int = 0) -> void:
	if not engines_states.state == engines_states.State.OFF:
		stop_engines()
		await engines_states.engines_are_off
	sc.send_event(engagement_mode_states.TRANS_OPEN_TO_CLOSING)
	sc.send_event(engagement_mode_states.TRANS_OPENING_TO_CLOSING)
	await engagement_mode_states.closing_finished
	close_finished.emit(id)


signal quick_close_finished(id: int)

func quick_close(id: int = 0) -> void:
	sc.send_event(engagement_mode_states.TRANS_OPEN_TO_QUICK_CLOSE)
	sc.send_event(engagement_mode_states.TRANS_OPENING_TO_QUICK_CLOSE)
	sc.send_event(engagement_mode_states.TRANS_CLOSING_TO_QUICK_CLOSE)
	quick_stop_engines(true)
	await engagement_mode_states.closing_finished
	quick_close_finished.emit(id)


## Engine Controls
## ---------------------------------------
func thrust() -> void:
	physics_mode_states.speed = engines_states.thrust_speed
	sc.send_event(engines_states.TRANS_OFF_TO_THRUST)
	sc.send_event(engines_states.TRANS_BURST_TO_THRUST)


func burst() -> void:
	physics_mode_states.speed = engines_states.burst_speed
	sc.send_event(engines_states.TRANS_OFF_TO_BURST)
	sc.send_event(engines_states.TRANS_THRUST_TO_BURST)


func stop_engines() -> void:
	physics_mode_states.speed = engines_states.off_speed
	sc.send_event(engines_states.TRANS_THRUST_TO_STOPPING)
	sc.send_event(engines_states.TRANS_BURST_TO_STOPPING)


func quick_stop_engines(keep_speed: bool = false) -> void:
	if not keep_speed:
		physics_mode_states.speed = engines_states.off_speed
	sc.send_event(engines_states.TRANS_THRUST_TO_QUICK_OFF)
	sc.send_event(engines_states.TRANS_BURST_TO_QUICK_OFF)


## Targeting Controls
## ---------------------------------------
func enable_targeting(to_acquiring: bool = false) -> void:
	if to_acquiring:
		sc.send_event(targeting_states.TRANS_DISABLED_TO_ACQUIRING)
	else:
		sc.send_event(targeting_states.TRANS_DISABLED_TO_NONE)


func disable_targeting() -> void:
	sc.send_event(targeting_states.TRANS_ACQUIRED_TO_DISABLED)
	sc.send_event(targeting_states.TRANS_ACQUIRING_TO_DISABLED)
	sc.send_event(targeting_states.TRANS_NONE_TO_DISABLED)
