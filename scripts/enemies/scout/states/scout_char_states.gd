class_name ScoutCharStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var look_at_target: Marker3D

## Parameters
@export_group("Parameters")
@export var lerp_factor: float = 5.0

## States Enum
enum State {MOVE = 0, TARGET = 1}
var state: State = State.MOVE

## State transition constants
const TRANS_TO_MOVE: String = "Char: to move"
const TRANS_TO_TARGET: String = "Char: to target"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")

## Settable Parameters
var previous_frame_control_axis: Vector2 = Vector2.ZERO
var control_axis: Vector2 = Vector2.ZERO
var lerped_control_axis: Vector2 = Vector2.ZERO
var speed: float = 6.0
var targeting_speed: float = 3.0
var z_axis_look_at_component: float
var control_axis_3D_look_at: Vector3 = Vector3.ZERO
var exhaust_intensity: float = 0.0


# move state
#----------------------------------------
func _on_move_state_entered() -> void:
	state = State.MOVE


func _on_move_state_physics_processing(delta: float) -> void:
	## Compute the movement vector
	var control_axis_length: float = control_axis.length()
	var control_axis_derivative: Vector2 = control_axis - previous_frame_control_axis
	var control_axis_3D: Vector3 = Vector3(control_axis.x, control_axis.y, 0.0)
	
	# z-axis component of the look at vector should slowly revert to 0 when idle
	if control_axis_length > 0.5 or (control_axis_derivative.length() > 0.2 and not control_axis.is_zero_approx()):
		control_axis_3D_look_at = control_axis_3D
		z_axis_look_at_component = (1.0 - control_axis_length * control_axis_length)
	else:
		z_axis_look_at_component = lerp(z_axis_look_at_component, 0.0, lerp_factor * 2.0 * delta)

	look_at_target.position = look_at_target.position.lerp(control_axis_3D_look_at + z_axis_look_at_component * Vector3.BACK, lerp_factor * delta)
	lerped_control_axis = Vector2(look_at_target.position.x, look_at_target.position.y)
	
	## Look at the marker
	char_node.look_at(look_at_target.global_position, Vector3.FORWARD)
	
	## move according to the movement vector too
	char_node.velocity = char_node.velocity.lerp(control_axis_3D * speed, lerp_factor * delta)
	
	
	## Exhaust matches velocity
	exhaust_intensity = lerp(exhaust_intensity, control_axis_length, lerp_factor * delta)
	scout.asset.set_exhaust_intensity(exhaust_intensity)
	
	## save previous frame control axis vector
	previous_frame_control_axis = control_axis


# target state
#----------------------------------------
func _on_target_state_entered() -> void:
	state = State.TARGET


func _on_target_state_physics_processing(delta: float) -> void:
	## Compute the movement vector
	lerped_control_axis = lerped_control_axis.lerp(control_axis, lerp_factor * delta)
	var lerped_control_axis_3D: Vector3 = Vector3(lerped_control_axis.x, lerped_control_axis.y, 0.0)
	
	## Update the look_at_target with the actual target
	look_at_target.global_position = look_at_target.global_position.lerp(scout.targeting_states.target.global_position, lerp_factor * delta)
	
	char_node.look_at(look_at_target.global_position, Vector3.FORWARD)
	
	## move according to the movement vector too
	char_node.velocity = lerped_control_axis_3D * targeting_speed
	
	## exhaust goes to 0
	exhaust_intensity = lerp(exhaust_intensity, 0.0, lerp_factor * delta)
	scout.asset.set_exhaust_intensity(exhaust_intensity)
	
	## save previous frame control axis vector
	previous_frame_control_axis = control_axis
