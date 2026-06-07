class_name ScoutPhysicsStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var cs: CompoundState

@export_group("State Mapping")
@export var state_map: Dictionary[State, StateChartState]

## States Enum
enum State {CHAR = 0, RIGID = 1, RAGDOLL = 2}
var state: State = State.CHAR

## State transition constants
const TRANS_TO_RIGID: String = "Physics: to rigid"
const TRANS_TO_CHAR: String = "Physics: to char"
const TRANS_TO_RAGDOLL: String = "Physics: to ragdoll"

## Scout nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")
@onready var rigid_node: InertNode = scout.get_node("RigidNode")

@onready var char_collision_shape: CollisionShape3D = scout.get_node("CharNode/CollisionShape3D")
@onready var rigid_collision_shape: CollisionShape3D = scout.get_node("RigidNode/CollisionShape3D")

@onready var track_transform_container: Node3D = scout.get_node("TrackTransformContainer")
@onready var track_position_container: Node3D = scout.get_node("TrackPositionContainer")

func _ready() -> void:
	## Assume Char mode
	char_collision_shape.disabled = false
	rigid_collision_shape.disabled = true


# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	state = State.CHAR
	
	## char node takes ownership of transform
	char_node.transform = rigid_node.transform
	
	## Turn on collision shape
	char_collision_shape.disabled = false


func _on_char_state_physics_processing(_delta: float) -> void:
	## Char mode isn't used yet here
	char_node.move_and_slide()
	
	## nodes that must follow the char node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position
	
	## rigid node follows char node
	# rigid_node.transform = char_node.transform


func _on_char_state_exited() -> void:
	## Turn off collision shape
	char_collision_shape.disabled = true


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
	state = State.RIGID
	
	## wake up the rigid node
	rigid_node.wake_up()
	
	## rigid node takes ownership of transform
	rigid_node.set_transform_and_velocity(char_node.global_transform, char_node.velocity)
	char_node.velocity = Vector3.ZERO
	
	## Enable rigid node collisions
	rigid_collision_shape.disabled = false


func _on_rigid_state_physics_processing(_delta: float) -> void:
	## nodes that must follow the rigid node
	track_transform_container.transform = rigid_node.transform
	track_position_container.position = rigid_node.position
	
	## char node follows rigid node
	# char_node.transform = rigid_node.transform


func _on_rigid_state_exited() -> void:
	## Turn off collision shape
	rigid_collision_shape.disabled = true
	
	## Put the rigid node to sleep
	rigid_node.sleep()


# ragdoll state
#----------------------------------------
func _on_ragdoll_state_entered() -> void:
	state = State.RAGDOLL


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
