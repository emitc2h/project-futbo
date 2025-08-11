class_name BallPhysicsStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var ball: Ball
@export var sc: StateChart

## States Enum
enum State {RIGID = 0, CHAR = 1}
var state: State = State.RIGID

## State transition constants
const TRANS_TO_CHAR: String = "Physics: to char"
const TRANS_TO_RIGID: String = "Physics: to rigid"

## Ball nodes controlled by this state
@onready var char_node: CharacterBody3D = ball.get_node("CharNode")
@onready var rigid_node: InertNode = ball.get_node("RigidNode")

@onready var track_transform_container: Node3D = ball.get_node("TrackTransformContainer")
@onready var track_position_container: Node3D = ball.get_node("TrackPositionContainer")

@onready var collision_shape_char: CollisionShape3D = ball.get_node("CharNode/CollisionShape3D")
@onready var collision_shape_rigid: CollisionShape3D = ball.get_node("RigidNode/CollisionShape3D")


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
	print("RIGID STATE ENTERED")
	state = State.RIGID
	
	## wake up the rigid node
	rigid_node.wake_up()
	
	## rigid node takes ownership of transform
	rigid_node.set_transform_and_velocity(char_node.global_transform, char_node.velocity)
	char_node.velocity = Vector3.ZERO
	
	## Enable rigid node collisions
	rigid_node.set_collision_layer_value(3, true)
	collision_shape_rigid.disabled = false


func _on_rigid_state_physics_processing(delta: float) -> void:
	## nodes tha must follow the rigid node
	track_transform_container.transform = rigid_node.transform
	track_position_container.position = rigid_node.position
	
	## char node follows rigid node
	char_node.transform = rigid_node.transform


func _on_rigid_state_exited() -> void:
	## Disable rigid node colliions
	rigid_node.set_collision_layer_value(3, false)
	collision_shape_rigid.disabled = true
	
	## Put the rigid node to sleep
	rigid_node.sleep()


# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	print("CHAR STATE ENTERED")
	state = State.CHAR
	
	## char node takes ownership of transform
	char_node.transform = rigid_node.transform

	## Enable char node collisions
	char_node.set_collision_layer_value(3, true)
	collision_shape_char.disabled = false


func _on_char_state_physics_processing(delta: float) -> void:
	## nodes tha must follow the rigid node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position
	
	## rigid node follows char node
	rigid_node.transform = char_node.transform


func _on_char_state_exited() -> void:
	## Disable char node collisions
	char_node.set_collision_layer_value(3, false)
	collision_shape_char.disabled = true
