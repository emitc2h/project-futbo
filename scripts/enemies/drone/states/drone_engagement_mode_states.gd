class_name DroneEngagementModeStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var targeting_states: DroneTargetingStates
@export var engines_states: DroneEnginesStates

## Parameters
@export_group("Float Distortion")
@export var float_distortion_open_pos_y: float = -1.2
@export var float_distortion_closed_pos_y: float = -1.0

## States Enum
enum State {CLOSED = 0, OPENING = 1, OPEN = 2, CLOSING = 3, QUICK_CLOSE = 4}
var state: State = State.CLOSED

## State transition constants
const TRANS_CLOSED_TO_OPENING: String = "Engagement Mode: closed to opening"

const TRANS_OPENING_TO_OPEN: String = "Engagement Mode: opening to open"
const TRANS_OPENING_TO_QUICK_CLOSE: String = "Engagement Mode: opening to quick close"
const TRANS_OPENING_TO_CLOSING: String = "Engagement Mode: opening to closing"

const TRANS_OPEN_TO_CLOSING: String = "Engagement Mode: open to closing"
const TRANS_OPEN_TO_QUICK_CLOSE: String = "Engagement Mode: open to quick close"

const TRANS_CLOSING_TO_CLOSED: String = "Engagement Mode: closing to closed"
const TRANS_CLOSING_TO_QUICK_CLOSE: String = "Engagement Mode: closing to quick close"
const TRANS_CLOSING_TO_OPENING: String = "Engagement Mode: closing to opening"

const TRANS_QUICK_CLOSE_TO_CLOSED: String = "Engagement Mode: quick close to closed"

## Drone nodes controlled by this state
@onready var float_distortion_mesh: MeshInstance3D = drone.get_node("TrackPositionContainer/Distortion")
@onready var model: DroneModel = drone.get_node("TrackTransformContainer/DroneModel")

## Signals
signal opening_finished
signal closing_finished


func _ready() -> void:
	model.anim_state_finished.connect(_on_anim_state_finished)


# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	state = State.CLOSED
	
	## Set the float distortion mesh position
	float_distortion_mesh.position.y = float_distortion_closed_pos_y
	
	closing_finished.emit()


func _on_closed_state_exited() -> void:
	drone.reset_engines()


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	state = State.OPENING


# open state
#----------------------------------------
func _on_open_state_entered() -> void:
	state = State.OPEN

	## Set the float distortion mesh position
	float_distortion_mesh.position.y = float_distortion_open_pos_y
	
	opening_finished.emit()


# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	state = State.CLOSING


# quick close state
#----------------------------------------
func _on_quick_close_state_entered() -> void:
	state = State.QUICK_CLOSE


# signal handling
#========================================
func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "open up":
		sc.send_event(TRANS_OPENING_TO_OPEN)
	
	if anim_name == "close up":
		sc.send_event(TRANS_CLOSING_TO_CLOSED)
	
	if anim_name in ["quick close", "thrust close"]:
		sc.send_event(TRANS_QUICK_CLOSE_TO_CLOSED)
