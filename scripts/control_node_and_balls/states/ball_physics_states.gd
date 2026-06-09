class_name BallPhysicsStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var ball: Ball
@export var sc: StateChart
@export var cs: CompoundState

@export_group("State Mapping")
@export var state_map: Dictionary[State, StateChartState]

@export_group("Physics Flags")
@export_flags_3d_physics var rigid_collision_layer: int
@export_flags_3d_physics var rigid_collision_mask: int
@export_flags_3d_physics var char_collision_layer: int
@export_flags_3d_physics var char_collision_mask: int

## States Enum, includes states for inheritors since we can't extend enums
enum State {RIGID = 0, CHAR = 1, WARPING = 2, RAGDOLL = 3}
var state: State = State.RIGID

## State transition constants
const TRANS_TO_CHAR: String = "Physics: to char"
const TRANS_TO_RIGID: String = "Physics: to rigid"

## Ball nodes controlled by this state
@onready var char_node: CharacterBody3D = ball.get_node("CharNode")
@onready var rigid_node: InertNode = ball.get_node("RigidNode")

@onready var track_transform_container: Node3D = ball.get_node("TrackTransformContainer")
@onready var track_position_container: Node3D = ball.get_node("TrackPositionContainer")

var do_not_transfer_y_velocity_to_rigid: bool = false


func _ready() -> void:
	## Initial state is RIGID
	rigid_node.collision_layer = rigid_collision_layer
	rigid_node.collision_mask = rigid_collision_mask
	char_node.collision_layer = 0
	char_node.collision_mask = 0


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
	state = State.RIGID
	
	## wake up the rigid node
	rigid_node.wake_up()
	
	## rigid node takes ownership of transform
	var velocity_to_hand_out: Vector3 = char_node.velocity
	if do_not_transfer_y_velocity_to_rigid:
		velocity_to_hand_out = Vector3(velocity_to_hand_out.x, 0.0, velocity_to_hand_out.z)
		do_not_transfer_y_velocity_to_rigid = false
	rigid_node.set_transform_and_velocity(char_node.global_transform, velocity_to_hand_out)
	char_node.velocity = Vector3.ZERO
	
	## Enable rigid node collisions
	rigid_node.collision_layer = rigid_collision_layer
	rigid_node.collision_mask = rigid_collision_mask


func _on_rigid_state_physics_processing(_delta: float) -> void:
	## nodes tha must follow the rigid node
	track_transform_container.transform = rigid_node.transform
	track_position_container.position = rigid_node.position


func _on_rigid_state_exited() -> void:
	## Disable rigid node collisions
	## Better to manipulate the collision layer than disabling the collision
	## shape entirely. I'm not sure why, but this is more reliable. The raycast
	## doesn't like re-enabled collision shapes for some reason.
	rigid_node.collision_layer = 0
	rigid_node.collision_mask = 0
	
	## Put the rigid node to sleep
	rigid_node.sleep()


# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	state = State.CHAR
	
	## char node takes ownership of transform
	char_node.transform = rigid_node.transform

	## Enable char node collisions
	char_node.collision_layer = char_collision_layer
	char_node.collision_mask = char_collision_mask


func _on_char_state_physics_processing(_delta: float) -> void:
	## nodes tha must follow the char node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position


func _on_char_state_exited() -> void:
	## Disable char node collisions
	char_node.collision_layer = 0
	char_node.collision_mask = 0


#=======================================================
# UTILITIES
#=======================================================
func get_global_position() -> Vector3:
	match(state):
		State.CHAR:
			return char_node.global_position
		_:
			return rigid_node.global_position


#=======================================================
# CONTROLS
#=======================================================
func set_initial_state(new_initial_state: State) -> void:
	cs._initial_state = state_map[new_initial_state]
