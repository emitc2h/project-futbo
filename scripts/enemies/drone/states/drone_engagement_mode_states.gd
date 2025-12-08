class_name DroneEngagementModeStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var targeting_states: DroneTargetingStates
@export var engines_states: DroneEnginesStates

## States Enum
enum State {CLOSED = 0, OPENING = 1, OPEN = 2, CLOSING = 3, QUICK_CLOSE = 4}
var state: State = State.CLOSED

## State transition constants
const TRANS_TO_OPENING: String = "Engagement Mode: to opening"
const TRANS_TO_OPEN: String = "Engagement Mode: to open"
const TRANS_TO_QUICK_CLOSE: String = "Engagement Mode: to quick close"
const TRANS_TO_CLOSING: String = "Engagement Mode: to closing"
const TRANS_TO_CLOSED: String = "Engagement Mode: to closed"

## Drone nodes controlled by this state
@onready var model: DroneModel = drone.get_node("TrackTransformContainer/DroneModel")
@onready var float_distortion_animation: DroneFloatDistortionAnimation = drone.get_node("FloatDistortionAnimation")
@onready var collision_shape_char: CollisionShape3D = drone.get_node("CharNode/CollisionShape3D")
@onready var collision_shape_capsule: CapsuleShape3D = collision_shape_char.shape as CapsuleShape3D

## When the height of a capsule is twice the radius it is a sphere of that radius
@onready var closed_collision_capsule_radius: float = collision_shape_capsule.radius
@onready var closed_collision_capsule_height: float = 2 * closed_collision_capsule_radius

@onready var open_collision_capsule_radius: float = closed_collision_capsule_radius
@onready var open_collision_capsule_height: float = 1.536

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
	float_distortion_animation.drone_closed_position()
	
	## Approximate the shape of the drone when closed (sphere: capsule.height == 2 * capsule.radius)
	collision_shape_capsule.height = closed_collision_capsule_height
	collision_shape_capsule.radius = closed_collision_capsule_radius
	
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
	float_distortion_animation.drone_open_position()
	
	## Approximate the shape of the drone when opened
	collision_shape_capsule.height = open_collision_capsule_height
	collision_shape_capsule.radius = open_collision_capsule_radius
	
	opening_finished.emit()


# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	model.spinners_disengage_target()
	state = State.CLOSING


# quick close state
#----------------------------------------
func _on_quick_close_state_entered() -> void:
	model.spinners_disengage_target()
	state = State.QUICK_CLOSE


# signal handling
#========================================
func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "open up":
		sc.send_event(TRANS_TO_OPEN)
	
	if anim_name == "close up":
		sc.send_event(TRANS_TO_CLOSED)
	
	if anim_name in ["quick close", "thrust close"]:
		sc.send_event(TRANS_TO_CLOSED)
