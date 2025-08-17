class_name DroneTargetingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var repr: DroneInternalRepresentation

## Parameters
@export_group("Vision Parameters")
@export var none_range: float = 4.0
@export var none_focus: float = 1.0
@export var acquiring_range: float = 8.0
@export var acquiring_focus: float = 4.0
@export var acquired_range: float = 10.0
@export var acquired_focus: float = 8.0

@export_group("Tracking Parameters")
@export var look_down_lerp_factor: float = 10.0
@export_range(0, 360, 0.1, "radians_as_degrees") var max_look_down_angle: float = 0.5
@export var look_up_lerp_factor: float = 5.0

## States Enum
enum State {DISABLED = 0, NONE = 1, ACQUIRING = 2, ACQUIRED = 3}
var state: State = State.NONE

## State transition constants
const TRANS_DISABLED_TO_NONE: String = "Targeting: disabled to none"
const TRANS_DISABLED_TO_ACQUIRING: String = "Targeting: disabled to acquiring"

const TRANS_NONE_TO_DISABLED: String = "Targeting: none to disabled"
const TRANS_NONE_TO_ACQUIRING: String = "Targeting: none to acquiring"
const TRANS_NONE_TO_ACQUIRED: String = "Targeting: none to acquired"

const TRANS_ACQUIRING_TO_DISABLED: String = "Targeting: acquiring to disabled"
const TRANS_ACQUIRING_TO_NONE: String = "Targeting: acquiring to none"
const TRANS_ACQUIRING_TO_ACQUIRED: String = "Targeting: acquiring to acquired"

const TRANS_ACQUIRED_TO_DISABLED: String = "Targeting: acquired to disabled"
const TRANS_ACQUIRED_TO_ACQUIRING: String = "Targeting: acquired to acquiring"

## Drone nodes controlled by this state
@onready var field_of_view: DroneFieldOfView = drone.get_node("TrackTransformContainer/FieldOfView")
@onready var char_node: CharacterBody3D = drone.get_node("CharNode")
@onready var drone_model: DroneModel = drone.get_node("TrackTransformContainer/DroneModel")

## Internal variables
var target: Node3D
var range_tween: Tween
var focus_tween: Tween
var time_spent_in_acquired_state: float = 0.0

## Timers
@onready var acquiring_timer: Timer = $AcquiringTimer

## Signals
signal target_acquired()
signal target_acquiring()
signal target_none()


## Utils
func scan_for_target() -> bool:
	if field_of_view.sees_target:
		if field_of_view.target is Player:
			target = field_of_view.target.target_marker
			repr.playerRepresentation.last_known_player_pos_x = field_of_view.target.global_position.x
			repr.playerRepresentation.player_is_dribbling = field_of_view.target.is_dribbling
		else:
			target = field_of_view.target
		return true
	return false


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	state = State.DISABLED
	field_of_view.enabled = false


func _on_disabled_state_exited() -> void:
	field_of_view.enabled = true


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE
	field_of_view.range = none_range
	field_of_view.focus = none_focus
	target_none.emit()


func _on_none_state_physics_processing(delta: float) -> void:
	if scan_for_target():
		sc.send_event(TRANS_NONE_TO_ACQUIRED)


# acquiring state
#----------------------------------------
func _on_acquiring_state_entered() -> void:
	state = State.ACQUIRING
	field_of_view.range = acquiring_range
	field_of_view.focus = acquiring_focus
	acquiring_timer.start()
	target_acquiring.emit()


func _on_acquiring_state_physics_processing(delta: float) -> void:
	if scan_for_target():
		sc.send_event(TRANS_ACQUIRING_TO_ACQUIRED)


func _on_acquiring_timer_timeout() -> void:
	acquiring_timer.stop()
	sc.send_event(TRANS_ACQUIRING_TO_NONE)


# acquired state
#----------------------------------------
func _on_acquired_state_entered() -> void:
	state = State.ACQUIRED
	## Bring the new raycast configuration gradually in
	if range_tween:
		range_tween.stop()
	range_tween = get_tree().create_tween()
	range_tween.tween_property(field_of_view, "range", acquired_range, 1.0)

	if focus_tween:
		focus_tween.stop()
	focus_tween = get_tree().create_tween()
	focus_tween.tween_property(field_of_view, "focus", acquired_focus, 1.0)

	## Let the drone look down at the target
	drone.physics_mode_states.look_down_lerp_factor = look_down_lerp_factor
	
	target_acquired.emit()
	
	## Target the spinners at the target
	drone_model.spinners_acquire_target(target)
	
	## Make the drone transition animations land on the targeting state
	drone_model.open_paths_to_targeting()
	
	## Track the cumulative amound of time spent in acquired state (reset it here)
	time_spent_in_acquired_state = 0.0


func _on_acquired_state_physics_processing(delta: float) -> void:
	if not scan_for_target():
		sc.send_event(TRANS_ACQUIRED_TO_ACQUIRING)
	else:
		## Compute where the target is, and the angle need to look down at it
		var pointer_to_target: Vector3 = char_node.global_position - target.global_position
		var new_rotation_x: float = min(asin(abs(pointer_to_target.y) / pointer_to_target.length()), max_look_down_angle)
		drone.physics_mode_states.look_down_angle = new_rotation_x
		
		## accumulate the time spent
		time_spent_in_acquired_state += delta


func _on_acquired_state_exited() -> void:
	## Look back up
	drone.physics_mode_states.look_down_lerp_factor = look_up_lerp_factor
	drone.physics_mode_states.look_down_angle = 0.0
	if range_tween:
		range_tween.stop()
	if focus_tween:
		focus_tween.stop()
	
	## Make the drone transition animations land on the idle state
	drone_model.open_paths_to_idle()
