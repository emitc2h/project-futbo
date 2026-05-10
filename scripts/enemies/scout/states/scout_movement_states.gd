class_name ScoutMovementStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var look_at_target: Marker3D

@onready var enter_plane_timer: Timer = $EnterPlaneTimer

@export_group("Parameters")
@export var enter_plane_duration: float = 1.0
@export var enter_plane_distance: float = 1.0
@export var nest_distance: float = 3.0


## States Enum
enum State {OUT_OF_PLANE_MOVEMENT = 0, ORBITING = 1, ENTER_PLANE = 2, IN_PLANE_MOVEMENT = 3}
var state: State = State.IN_PLANE_MOVEMENT

## State transition constants
const TRANS_TO_OUT_OF_PLANE_MOVEMENT: String = "Movement: to out of plane movement"
const TRANS_TO_ENTER_PLANE: String = "Movement: to enter plane"
const TRANS_TO_IN_PLANE_MOVEMENT: String = "Movement: to in plane movement"
const TRANS_TO_ORBITING: String = "Movement: to orbiting"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")

## Settable Parameters
var player_is_out_of_plane_movement_target: bool = false
var player_target_offset_x: float = 0.0
var player_target_offset_y: float = 0.0
var out_of_plane_movement_target_node: Node3D
var out_of_plane_movement_target: Vector3 = Vector3.ZERO

## Internal parameters
var _exhaust_intensity: float = 0.0
var tw_enter_plane_pos_z: Tween
var enter_plane_distance_to_nest_x: float
var enter_plane_distance_to_nest_y: float
var is_enter_plane_ready: bool = false

## Signals
signal enter_plane_ready
signal has_entered_plane
signal has_left_plane


func _ready() -> void:
	enter_plane_timer.wait_time = enter_plane_duration


# out of plane movement state
#----------------------------------------
func _on_out_of_plane_movement_state_entered() -> void:
	state = State.OUT_OF_PLANE_MOVEMENT


func _on_out_of_plane_movement_state_physics_processing(delta: float) -> void:
	## Update the look-at-target with the provided target
	update_out_of_plane_movement_target()
	
	## Check if enter plane ready
	if abs(char_node.global_position.distance_to(out_of_plane_movement_target)) < enter_plane_distance:
		if not is_enter_plane_ready:
			is_enter_plane_ready = true
			enter_plane_ready.emit()
	else:
		is_enter_plane_ready = false
	
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


# enter plane state
#----------------------------------------
func _on_enter_plane_state_entered() -> void:
	state = State.ENTER_PLANE
	
	## Neutralize all velocity along the z axis to "park" the char node on the z axis with a tween
	char_node.velocity.z = 0.0
	
	if tw_enter_plane_pos_z: tw_enter_plane_pos_z.kill()
	tw_enter_plane_pos_z = create_tween()
	tw_enter_plane_pos_z.tween_property(char_node, "global_position:z", 0.0, enter_plane_duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(char_node.global_position.z)
		
	enter_plane_distance_to_nest_x = abs(char_node.global_position.x - out_of_plane_movement_target.x)
	enter_plane_distance_to_nest_y = abs(char_node.global_position.y - out_of_plane_movement_target.y)
	
	enter_plane_timer.start()


func _on_enter_plane_state_physics_processing(delta: float) -> void:
	## exhaust goes to 0 since preparing to target in plane
	_exhaust_intensity = lerp(_exhaust_intensity, 0.0, scout.lerp_factor * delta)
	scout.asset.set_exhaust_intensity(_exhaust_intensity)
	
	## Update the look_at_target with the player
	look_at_target.global_position = look_at_target.global_position.lerp(Representations.player_target_marker.global_position, scout.lerp_factor * delta)
	
	## Look at the target
	char_node.look_at(look_at_target.global_position)
	
	## Move the char_node toward the destination node along the xy-plane only
	update_out_of_plane_movement_target()
	
	char_node.velocity.x = (out_of_plane_movement_target.x - char_node.global_position.x) / (enter_plane_distance_to_nest_x + 1.0)
	char_node.velocity.y = (out_of_plane_movement_target.y - char_node.global_position.y) / (enter_plane_distance_to_nest_y + 1.0)


# in plane movement state
#----------------------------------------
func _on_in_plane_movement_state_entered() -> void:
	state = State.IN_PLANE_MOVEMENT
	has_entered_plane.emit()
	
	char_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, true)
	## Movement delegated to the In Plane Movement state machine


func _on_in_plane_movement_state_exited() -> void:
	char_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, false)
	has_left_plane.emit()


# utilities
#========================================
func update_out_of_plane_movement_target() -> void:
	if player_is_out_of_plane_movement_target:
		out_of_plane_movement_target = Representations.player_target_marker.global_position\
			+ Vector3.RIGHT * player_target_offset_x\
			+ Vector3.UP * player_target_offset_y
	elif out_of_plane_movement_target_node:
		out_of_plane_movement_target = out_of_plane_movement_target_node.global_position


# controls
#========================================
func set_player_as_out_of_plane_movement_target() -> void:
	player_target_offset_x = 0.0
	player_target_offset_y = 0.0
	player_is_out_of_plane_movement_target = true
	out_of_plane_movement_target_node = null


func set_node_as_out_of_plane_movement_target(node: Node3D) -> void:
	out_of_plane_movement_target_node = node
	player_is_out_of_plane_movement_target = false


func set_nest_as_out_of_plane_target(nest: Enums.Direction) -> void:
	set_player_as_out_of_plane_movement_target()
	player_target_offset_y = randf_range(0.0, 1.5)
	match(nest):
		Enums.Direction.LEFT:
			player_target_offset_x = -nest_distance
		Enums.Direction.RIGHT:
			player_target_offset_x = nest_distance


# signals
#========================================
func _on_enter_plane_timer_timeout() -> void:
	enter_plane_timer.stop()
	sc.send_event(TRANS_TO_IN_PLANE_MOVEMENT)
