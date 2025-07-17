class_name DroneEngagementModeStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: DroneV2
@export var sc: StateChart

## Parameters

## States Enum
enum State {CLOSED = 0, OPENING = 1, OPEN = 2, CLOSING = 3, QUICK_CLOSE = 4}
var state: State = State.CLOSED

## State transition constants

## Drone nodes controlled by this state
@onready var closed_collision_shape_char: CollisionShape3D = drone.get_node("CharNode/ClosedCollisionShape3D")
@onready var open_collision_shape_char: CollisionShape3D = drone.get_node("CharNode/OpenCollisionShape3D")
@onready var float_distortion_mesh: MeshInstance3D = drone.get_node("TrackPositionContainer/Distortion")
@onready var model_anim_tree: AnimationTree = drone.get_node("TrackTransformContainer/DroneModel/AnimationTree")
@onready var anim_state: AnimationNodeStateMachinePlayback


func _ready() -> void:
	anim_state = model_anim_tree.get("parameters/playback")


# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	state = State.CLOSED


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	state = State.OPENING


# open state
#----------------------------------------
func _on_open__engines_state_entered() -> void:
	state = State.OPEN


# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	state = State.CLOSING


# quick close state
#----------------------------------------
func _on_quick_close_state_entered() -> void:
	state = State.QUICK_CLOSE
