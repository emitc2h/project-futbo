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
var control_axis: Vector2 = Vector2.ZERO
var lerped_control_axis: Vector2 = Vector2.ZERO
var speed: float = 5.0


# move state
#----------------------------------------
func _on_move_state_entered() -> void:
	state = State.MOVE


func _on_move_state_physics_processing(delta: float) -> void:
	## Compute the movement vector
	lerped_control_axis = lerped_control_axis.lerp(control_axis, lerp_factor * delta)
	var control_axis_length: float = lerped_control_axis.length()
	var lerped_control_axis_3D: Vector3 = Vector3(lerped_control_axis.x, lerped_control_axis.y, 0.0)
	
	## Update the look_at_target position based on the control_axis
	look_at_target.position =  lerped_control_axis_3D + (1.0 - control_axis_length * control_axis_length) * Vector3.BACK
	
	## Look at the marker, but only if there is some input
	if not lerped_control_axis.is_zero_approx():
		char_node.look_at(look_at_target.global_position, Vector3.FORWARD)
	
	## move according to the movement vector too
	char_node.velocity = lerped_control_axis_3D * speed


# target state
#----------------------------------------
func _on_target_state_entered() -> void:
	state = State.TARGET


func _on_target_state_physics_processing(delta: float) -> void:
	## Compute the movement vector
	lerped_control_axis = lerped_control_axis.lerp(control_axis, lerp_factor * delta)
	var lerped_control_axis_3D: Vector3 = Vector3(lerped_control_axis.x, lerped_control_axis.y, 0.0)
	
	## Update the look_at_target with the actual target
	look_at_target.global_position =  scout.targeting_states.target.global_position
	
	char_node.look_at(look_at_target.global_position, Vector3.FORWARD)
	
	## move according to the movement vector too
	char_node.velocity = lerped_control_axis_3D * speed
