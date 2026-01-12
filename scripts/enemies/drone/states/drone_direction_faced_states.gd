class_name DroneDirectionFacedStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart

## Parameters
@export_group("Parameters")
@export var rotation_lerp_factor: float = 5.0

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
@onready var jerk_timer: Timer = $JerkTimer

## Internal constants
const FACE_RIGHT_Y_ROT = Vector3(0.0, PI/2, 0.0)
const FACE_LEFT_Y_ROT = Vector3(0.0, -PI/2, 0.0)

## Internal variables
var tween: Tween
var target_vec: Vector3 = Vector3.ZERO
var accumulated_damage: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Signals
signal is_now_facing_right
signal is_now_facing_left


func _rotate_toward(vector: Vector3, delta: float) -> void:
	var target_orientation: Quaternion = Quaternion.from_euler(vector)
	var current_orientation: Quaternion = Quaternion.from_euler(char_node.rotation)
	var new_orientation: Quaternion = current_orientation.slerp(target_orientation, rotation_lerp_factor * delta)
	char_node.rotation = new_orientation.get_euler()


# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	state = State.FACE_RIGHT
	mode = Mode.FACING
	is_now_facing_right.emit()


func _on_face_right_state_physics_processing(delta: float) -> void:
	if target_vec != Vector3.ZERO:
		var x_rot: Vector3 = Vector3.RIGHT * Vector3.LEFT.angle_to(target_vec)
		self._rotate_toward(FACE_RIGHT_Y_ROT + x_rot, delta)
	else:
		self._rotate_toward(FACE_RIGHT_Y_ROT, delta)


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	state = State.FACE_LEFT
	mode = Mode.FACING
	is_now_facing_left.emit()


func _on_face_left_state_physics_processing(delta: float) -> void:
	if target_vec != Vector3.ZERO:
		var x_rot: Vector3 = Vector3.RIGHT * Vector3.RIGHT.angle_to(target_vec)
		self._rotate_toward(FACE_LEFT_Y_ROT + x_rot, delta)
	else:
		self._rotate_toward(FACE_LEFT_Y_ROT, delta)


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


#=======================================================
# CONTROLS
#=======================================================
func damage_hit(strength: float) -> void:
	accumulated_damage += strength / 5.0
	jerk_timer.wait_time = 0.05
	jerk_timer.start()


#=======================================================
# Signals
#=======================================================
func _on_jerk_timer_timeout() -> void:
	var jerk_factor: float = (1.0 + accumulated_damage / (1.0 + accumulated_damage))
	if rng.randf() > 0.5:
		char_node.rotate_x(0.2 * (0.5 - rng.randf()) * jerk_factor)
	else:
		char_node.rotate_z(0.2 * (0.5 - rng.randf()) * jerk_factor)
	jerk_timer.wait_time = rng.randf() * 5.0 / jerk_factor
	jerk_timer.start()
