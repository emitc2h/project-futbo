class_name BallControlStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var ball: Ball
@export var sc: StateChart

# Configurables
@export_group("Dribble Parameters")
@export var dribble_rotation_speed: float = 4.0
@export var dribble_velocity_offset: float = 0.0063662
@export var ball_snap_velocity: float = 6.0

## States Enum
enum State {FREE = 0, DRIBBLED = 1, HELD = 2}
var state: State = State.FREE

## State transition constants
const TRANS_FREE_TO_DRIBBLED: String = "Control: free to dribbled"
const TRANS_FREE_TO_HELD: String = "Control: free to held"

const TRANS_TO_FREE: String = "Control: to free"

## Ball nodes controlled by this state
@onready var char_node: CharacterBody3D = ball.get_node("CharNode")

# Internal properties
var dribbler_id: int
var is_owned: bool = false

var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")
var dribble_time: float
var dribble_marker_position: Vector3
var player_velocity: Vector3
var direction_faced: Enums.Direction = Enums.Direction.RIGHT


func _ready() -> void:
	Signals.active_dribble_marker_position_updated.connect(_on_active_dribble_marker_position_updated)
	Signals.player_velocity_updated.connect(_on_player_velocity_updated)
	Signals.facing_left.connect(_on_facing_left)
	Signals.facing_right.connect(_on_facing_right)


# free state
#----------------------------------------
func _on_free_state_entered() -> void:
	print("FREE STATE ENTERED")
	state = State.FREE
	if ball.physics_states.state != ball.physics_states.State.RIGID:
		sc.send_event(ball.physics_states.TRANS_TO_RIGID)


# dribbled state
#----------------------------------------
func _on_dribbled_state_entered() -> void:
	print("DRIBBLED STATE ENTERED")
	state = State.DRIBBLED
	if ball.physics_states.state != ball.physics_states.State.CHAR:
		sc.send_event(ball.physics_states.TRANS_TO_CHAR)
	dribble_time = 0.0


func _on_dribbled_state_physics_processing(delta: float) -> void:
	dribble_time += delta
	
	## Attract the ball to the dribble marker
	var a: float = dribble_marker_position.x
	var b: float = char_node.global_position.x
	var dribble_marker_distance: float = abs(a - b)
	var dribble_marker_position_delta: float = (a - b)/dribble_marker_distance
	
	# Match player velocity
	char_node.velocity.x = player_velocity.x
	if dribble_marker_distance > 0.05:
		char_node.velocity.x += dribble_marker_position_delta * ball_snap_velocity
	
	# Use gravity when not touching the ground
	if not char_node.is_on_floor():
		print("adding gravity")
		char_node.velocity.y += gravity * delta
	
	# Compute colliding behavior
	char_node.move_and_slide()
	
	# Ball spinning animation
	char_node.rotation.z = -dribble_time * direction_faced * \
		 dribble_rotation_speed * PI


func _on_dribbled_state_exited() -> void:
	## Make sure not to pass the snap velocity along to the rigid node
	char_node.velocity.x = player_velocity.x


# held state
#----------------------------------------
func _on_held_state_entered() -> void:
	state = State.HELD


# signal handling
#========================================
func _on_active_dribble_marker_position_updated(pos: Vector3) -> void:
	dribble_marker_position = pos


func _on_player_velocity_updated(vel: Vector3) -> void:
	player_velocity = vel


func _on_facing_left() -> void:
	direction_faced = Enums.Direction.LEFT


func _on_facing_right() -> void:
	direction_faced = Enums.Direction.RIGHT
