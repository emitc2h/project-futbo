class_name ScoutMovementStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var look_at_target: Marker3D


## States Enum
enum State {OUT_OF_PLANE_MOVEMENT = 0, ORBITING = 1, IN_PLANE_MOVEMENT = 2}
var state: State = State.IN_PLANE_MOVEMENT

## State transition constants
const TRANS_TO_OUT_OF_PLANE_MOVEMENT: String = "Movement: to out of plane movement"
const TRANS_TO_IN_PLANE_MOVEMENT: String = "Movement: to in plane movement"
const TRANS_TO_ORBITING: String = "Movement: to orbiting"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")

## Settable Parameters
var player_is_out_of_plane_movement_target: bool = false
var out_of_plane_movement_target_node: Node3D
var out_of_plane_movement_target: Vector3 = Vector3.ZERO

## Internal parameters
var _exhaust_intensity: float = 0.0


# out of plane movement state
#----------------------------------------
func _on_out_of_plane_movement_state_entered() -> void:
	state = State.OUT_OF_PLANE_MOVEMENT


func _on_out_of_plane_movement_state_physics_processing(delta: float) -> void:
	## Update the look-at-target with the provided target
	update_out_of_plane_movement_target()
	look_at_target.global_position = look_at_target.global_position.lerp(out_of_plane_movement_target, scout.lerp_factor * delta)
	
	## Look at the marker
	char_node.look_at(look_at_target.global_position)
	
	## Compute direction vector
	var look_at_direction_vector: Vector3 = (look_at_target.global_position - char_node.global_position).normalized()
	
	## Move the scout along that direction
	char_node.velocity = char_node.velocity.lerp(look_at_direction_vector * scout.speed, scout.lerp_factor * delta)
	
	## Exhaust matches velocity
	_exhaust_intensity = lerp(_exhaust_intensity, 1.0, scout.lerp_factor * delta)
	scout.asset.set_exhaust_intensity(_exhaust_intensity)

# orbiting state
#----------------------------------------
func _on_orbiting_state_entered() -> void:
	state = State.ORBITING
	scout.orbiting_states._exhaust_intensity = _exhaust_intensity


# in plane movement state
#----------------------------------------
func _on_in_plane_movement_state_entered() -> void:
	state = State.IN_PLANE_MOVEMENT
	## Movement delegated to the In Plane Movement state machine


# utilities
#========================================
func update_out_of_plane_movement_target() -> void:
	if player_is_out_of_plane_movement_target:
		out_of_plane_movement_target = Representations.player_target_marker.global_position
	elif out_of_plane_movement_target_node:
		out_of_plane_movement_target = out_of_plane_movement_target_node.global_position


# controls
#========================================
func set_player_as_out_of_plane_movement_target() -> void:
	player_is_out_of_plane_movement_target = true
	out_of_plane_movement_target_node = null


func set_node_as_out_of_plane_movement_target(node: Node3D) -> void:
	out_of_plane_movement_target_node = node
	player_is_out_of_plane_movement_target = false
