class_name BallPhysicsStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var ball: Ball
@export var sc: StateChart

## States Enum
enum State {RIGID = 0, CHAR = 1, WARPING = 2}
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

var do_not_transfer_y_velocity_to_rigid: bool = false


func _ready() -> void:
	## Otherwise both might be enabled
	rigid_node.set_collision_layer_value(3, true)
	char_node.set_collision_layer_value(3, false)


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
	rigid_node.set_collision_layer_value(3, true)


func _on_rigid_state_physics_processing(_delta: float) -> void:
	## nodes tha must follow the rigid node
	track_transform_container.transform = rigid_node.transform
	track_position_container.position = rigid_node.position
	
	## char node follows rigid node
	char_node.transform = rigid_node.transform


func _on_rigid_state_exited() -> void:
	## Disable rigid node collisions
	## Better to manipulate the collision layer than disabling the collision shape entirely. I'm not sure why, but this
	## is more reliable. The raycast doesn't like re-enabled collision shapes for some reason.
	rigid_node.set_collision_layer_value(3, false)
	
	## Put the rigid node to sleep
	rigid_node.sleep()


# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	state = State.CHAR
	
	## char node takes ownership of transform
	char_node.transform = rigid_node.transform

	## Enable char node collisions
	char_node.set_collision_layer_value(3, true)


func _on_char_state_physics_processing(_delta: float) -> void:
	## nodes tha must follow the char node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position
	
	## rigid node follows char node
	rigid_node.transform = char_node.transform


func _on_char_state_exited() -> void:
	## Disable char node collisions
	char_node.set_collision_layer_value(3, false)
