class_name DroneTargetingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: DroneV2
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
@export var look_down_lerp_factor: float = 4.0
@export_range(0, 360, 0.1, "radians_as_degrees") var max_look_down_angle: float = 0.5
@export var look_down_target_height: float = 1.5

## States Enum
enum State {DISABLED = 0, NONE = 1, ACQUIRING = 2, ACQUIRED = 3}
var state: State = State.NONE

## State transition constants
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

## Internal variables
var target: Node3D


## Utils
func scan_for_target() -> bool:
	if field_of_view.sees_target:
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


func _on_none_state_physics_processing(delta: float) -> void:
	if scan_for_target():
		sc.send_event(TRANS_NONE_TO_ACQUIRED)


# acquiring state
#----------------------------------------
func _on_acquiring_state_entered() -> void:
	state = State.ACQUIRING
	field_of_view.range = acquiring_range
	field_of_view.focus = acquiring_focus


func _on_acquiring_state_physics_processing(delta: float) -> void:
	if scan_for_target():
		sc.send_event(TRANS_ACQUIRING_TO_ACQUIRED)


# acquired state
#----------------------------------------
func _on_acquired_state_entered() -> void:
	state = State.ACQUIRED
	field_of_view.range = acquired_range
	field_of_view.focus = acquired_focus


func _on_acquired_state_physics_processing(delta: float) -> void:
	var pointer_to_target: Vector3 = char_node.global_position - target.global_position - Vector3.UP * look_down_target_height
	var new_rotation_x: float = min(asin(abs(pointer_to_target.y) / pointer_to_target.length()), max_look_down_angle)
	char_node.rotation.x = lerp(char_node.rotation.x, new_rotation_x, look_down_lerp_factor)
