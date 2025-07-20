class_name DroneEngagementModeStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: DroneV2
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
@onready var closed_collision_shape_char: CollisionShape3D = drone.get_node("CharNode/ClosedCollisionShape3D")
@onready var open_collision_shape_char: CollisionShape3D = drone.get_node("CharNode/OpenCollisionShape3D")
@onready var float_distortion_mesh: MeshInstance3D = drone.get_node("TrackPositionContainer/Distortion")
@onready var model_anim_tree: AnimationTree = drone.get_node("TrackTransformContainer/DroneModel/AnimationTree")
@onready var anim_state: AnimationNodeStateMachinePlayback

## Signals
signal opening_finished
signal closing_finished


func _ready() -> void:
	anim_state = model_anim_tree.get("parameters/playback")
	model_anim_tree.animation_finished.connect(_on_animation_finished)


#func _physics_process(delta: float) -> void:
	#print(anim_state.get_current_node())


# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	state = State.CLOSED
	# TODO: Become invulnerable
	
	## Use the closed collision shape when closed
	closed_collision_shape_char.disabled = false
	open_collision_shape_char.disabled = true
	
	## Set the float distortion mesh position
	float_distortion_mesh.position.y = float_distortion_closed_pos_y
	
	closing_finished.emit()


func _on_closed_to_opening_taken() -> void:
	anim_state.travel("open up")


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	state = State.OPENING
	
	# TODO: Become defendable


func _on_opening_to_closing_taken() -> void:
	anim_state.travel("close up")


func _on_opening_to_quick_close_taken() -> void:
	anim_state.travel("quick close")


# open state
#----------------------------------------
func _on_open_state_entered() -> void:
	state = State.OPEN
	
	## Use the open collision shape when open
	open_collision_shape_char.disabled = false
	closed_collision_shape_char.disabled = true

	## Set the float distortion mesh position
	float_distortion_mesh.position.y = float_distortion_open_pos_y
	
	# TODO: Become defendable
	
	opening_finished.emit()


func _on_open_to_closing_taken() -> void:
	anim_state.travel("close up")


func _on_open_to_quick_close_taken() -> void:
	if engines_states.state == engines_states.State.OFF:
		anim_state.travel("quick close")
	else:
		anim_state.travel("thrust close")



# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	state = State.CLOSING
	
	# TODO: Become defendable


func _on_closing_to_quick_close_taken() -> void:
	anim_state.travel("quick close")


# quick close state
#----------------------------------------
func _on_quick_close_state_entered() -> void:
	state = State.QUICK_CLOSE
	
	# TODO: Become defendable


# signal handling
#========================================
func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "OpenUp":
		sc.send_event(TRANS_OPENING_TO_OPEN)
	
	if anim_name == "CloseUp":
		sc.send_event(TRANS_CLOSING_TO_CLOSED)
	
	if anim_name in ["QuickClose", "ThrustClose"]:
		sc.send_event(TRANS_QUICK_CLOSE_TO_CLOSED)
