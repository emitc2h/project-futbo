class_name ScoutPhysicsStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart

## States Enum
enum State {CHAR = 0, RIGID = 1, RAGDOLL = 2, DEAD = 3}
var state: State = State.CHAR

## State transition constants
const TRANS_TO_RIGID: String = "Physics: to rigid"
const TRANS_TO_CHAR: String = "Physics: to char"
const TRANS_TO_RAGDOLL: String = "Physics: to ragdoll"
const TRANS_TO_DEAD: String = "Physics: to dead"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")
@onready var rigid_node: InertNode = scout.get_node("RigidNode")

@onready var track_transform_container: Node3D = scout.get_node("TrackTransformContainer")
@onready var track_position_container: Node3D = scout.get_node("TrackPositionContainer")

@onready var collision_shape_char: CollisionShape3D = scout.get_node("CharNode/CollisionShape3D")
@onready var collision_shape_rigid: CollisionShape3D = scout.get_node("RigidNode/CollisionShape3D")


func _ready() -> void:
	collision_shape_rigid.disabled = true
	collision_shape_char.disabled = false


# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	state = State.CHAR
	
	## char node takes ownership of transform
	char_node.transform = rigid_node.transform
	
	## Turn on collision shape
	collision_shape_char.disabled = false


func _on_char_state_physics_processing(_delta: float) -> void:
	char_node.move_and_slide()
	
	## nodes that must follow the char node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position
	
	## rigid node follows char node
	rigid_node.transform = char_node.transform


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
	state = State.RIGID


# ragdoll state
#----------------------------------------
func _on_ragdoll_state_entered() -> void:
	state = State.RAGDOLL


# dead state
#----------------------------------------
func _on_dead_state_entered() -> void:
	state = State.DEAD


# utilities
#========================================
func get_global_position() -> Vector3:
	match(state):
		State.CHAR:
			return char_node.global_position
		_:
			return rigid_node.global_position
	
