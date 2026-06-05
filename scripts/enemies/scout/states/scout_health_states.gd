class_name ScoutHealthStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var repulsor_field: ScoutRepulsorField

## States Enum
enum State {ACTIVE = 0, INCAPACITATED = 1, DEAD = 2}
var state: State = State.ACTIVE

## State transition constants
const TRANS_TO_ACTIVE: String = "Health: to active"
const TRANS_TO_INCAPACITATED: String = "Health: to incapacitated"
const TRANS_TO_DEAD: String = "Health: to dead"

## Scout nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")
@onready var rigid_node: InertNode = scout.get_node("RigidNode")

@onready var track_transform_container: Node3D = scout.get_node("TrackTransformContainer")
@onready var track_position_container: Node3D = scout.get_node("TrackPositionContainer")

@onready var char_collision_shape: CollisionShape3D = scout.get_node("CharNode/CollisionShape3D")
@onready var rigid_collision_shape: CollisionShape3D = scout.get_node("RigidNode/CollisionShape3D")


func _ready() -> void:
	char_collision_shape.disabled = false
	rigid_collision_shape.disabled = true


# active state
#----------------------------------------
func _on_active_state_entered() -> void:
	state = State.ACTIVE

	## active state is always char
	char_node.transform = rigid_node.transform
	char_collision_shape.disabled = false


func _on_active_state_physics_processing(delta: float) -> void:
	## Factor in the repulsor field
	var repulsor_field_force: Vector3 = repulsor_field.get_repulsion_force()
	char_node.velocity += repulsor_field_force * delta
	
	char_node.move_and_slide()
	
	## nodes that must follow the char node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position
	
	## rigid node follows char node
	rigid_node.transform = char_node.transform
	
	## Active state delegates the movement definition to the Movement States


func _on_active_state_exited() -> void:
	char_collision_shape.disabled = true


# incapacitated state
#----------------------------------------
func _on_incapacitated_state_entered() -> void:
	state = State.INCAPACITATED
	
	## Incapacitated state is always expected to be entered when in plane movement
	rigid_node.set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, true)
	
	## Incapacitated state delegates the physics mode to the Physics states


# dead state
#----------------------------------------
func _on_dead_state_entered() -> void:
	state = State.DEAD
