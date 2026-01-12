class_name DroneTargetingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart

## Parameters
@export_group("Vision Parameters")
@export var none_range: float = 4.0
@export var none_focus: float = 1.0
@export var acquiring_range: float = 8.0
@export var acquiring_focus: float = 4.0
@export var acquired_range: float = 10.0
@export var acquired_focus: float = 8.0

@export_group("Tracking Parameters")
@export_range(0, 360, 0.1, "radians_as_degrees") var max_look_down_angle: float = 1.0

## States Enum
enum State {DISABLED = 0, NONE = 1, ACQUIRING = 2, ACQUIRED = 3}
var state: State = State.NONE

## State transition constants
const TRANS_TO_DISABLED: String = "Targeting: to disabled"
const TRANS_TO_NONE: String = "Targeting: to none"
const TRANS_TO_ACQUIRING: String = "Targeting: to acquiring"
const TRANS_TO_ACQUIRED: String = "Targeting: to acquired"

## Drone nodes controlled by this state
@onready var field_of_view: DroneFieldOfView = drone.get_node("TrackTransformContainer/FieldOfView")
@onready var char_node: CharacterBody3D = drone.get_node("CharNode")
@onready var drone_model: DroneModel = drone.get_node("TrackTransformContainer/DroneModel")

## Target Type
enum TargetType {PLAYER = 0, CONTROL_NODE = 1, OTHER = 2}
var target_type: TargetType = TargetType.PLAYER

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
		match(target_type):
			TargetType.PLAYER:
				if field_of_view.target.is_in_group("PlayerGroup"):
					target = field_of_view.target.target_marker
			TargetType.CONTROL_NODE:
				if field_of_view.target.is_in_group("ControlNodeGroup"):
					target = field_of_view.target.target_marker
			TargetType.OTHER:
				target = field_of_view.target
		return true
	return false


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	acquiring_timer.stop()
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


func _on_none_state_physics_processing(_delta: float) -> void:
	if scan_for_target():
		sc.send_event(TRANS_TO_ACQUIRED)


# acquiring state
#----------------------------------------
func _on_acquiring_state_entered() -> void:
	state = State.ACQUIRING
	field_of_view.range = acquiring_range
	field_of_view.focus = acquiring_focus
	acquiring_timer.start()
	target_acquiring.emit()


func _on_acquiring_state_physics_processing(_delta: float) -> void:
	if scan_for_target():
		sc.send_event(TRANS_TO_ACQUIRED)


func _on_acquiring_timer_timeout() -> void:
	acquiring_timer.stop()
	if state == State.ACQUIRING:
		sc.send_event(TRANS_TO_NONE)


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
	
	target_acquired.emit()
	
	## Make the drone transition animations land on the targeting state
	drone_model.open_paths_to_targeting()
	
	## Track the cumulative amound of time spent in acquired state (reset it here)
	time_spent_in_acquired_state = 0.0


func _on_acquired_state_physics_processing(delta: float) -> void:
	if not scan_for_target():
		sc.send_event(TRANS_TO_ACQUIRING)
	else:
		## Compute where the target is, and the angle needed to look down at it
		drone.direction_faced_states.target_vec = (char_node.global_position - target.global_position).normalized()
		
		## accumulate the time spent
		time_spent_in_acquired_state += delta


func _on_acquired_state_exited() -> void:
	## Look back up
	drone.direction_faced_states.target_vec = Vector3.ZERO
	
	if range_tween:
		range_tween.stop()
	if focus_tween:
		focus_tween.stop()
	
	## Make the drone transition animations land on the idle state
	drone_model.open_paths_to_idle()
