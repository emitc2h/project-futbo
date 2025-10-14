class_name DronePositionStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var repr: DroneInternalRepresentation
@export var patrol_marker_1: Marker3D
@export var patrol_marker_2: Marker3D

## States Enum
enum State {BETWEEN_PATROL_MARKERS = 0, OUTSIDE_PATROL_MARKERS = 1}
var state: State = State.BETWEEN_PATROL_MARKERS

## State transition constants
const TRANS_TO_OUTSIDE_PATROL_MARKERS: String = "Position: to outside patrol markers"
const TRANS_TO_BETWEEN_PATROL_MARKERS: String = "Behavior: to between patrol markers"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = drone.get_node("CharNode")

## Internal variables
var left_marker_pos_x: float
var right_marker_pos_x: float

## Signals
signal between_markers
signal outside_markers

## Utils
func is_between_patrol_markers() -> bool:
	var drone_pos_x: float = char_node.global_position.x
	if drone_pos_x > left_marker_pos_x and drone_pos_x <= right_marker_pos_x:
		return true
	return false
	

func _ready() -> void:
	var x1: float = patrol_marker_1.global_position.x
	var x2: float = patrol_marker_2.global_position.x
	
	if x2 > x1:
		right_marker_pos_x = x2
		left_marker_pos_x = x1
	else:
		right_marker_pos_x = x1
		left_marker_pos_x = x2
	
	repr.worldRepresentation.patrol_marker_1_pos_x = x1
	repr.worldRepresentation.patrol_marker_2_pos_x = x2


# between patrol markers state
#----------------------------------------
func _on_between_patrol_markers_state_entered() -> void:
	state = State.BETWEEN_PATROL_MARKERS
	between_markers.emit()


func _on_between_patrol_markers_state_physics_processing(_delta: float) -> void:
	if not is_between_patrol_markers():
		sc.send_event(TRANS_TO_OUTSIDE_PATROL_MARKERS)


# outside patrol markers state
#----------------------------------------
func _on_outside_patrol_markers_state_entered() -> void:
	state = State.OUTSIDE_PATROL_MARKERS
	outside_markers.emit()


func _on_outside_patrol_markers_state_physics_processing(_delta: float) -> void:
	if is_between_patrol_markers():
		sc.send_event(TRANS_TO_BETWEEN_PATROL_MARKERS)
