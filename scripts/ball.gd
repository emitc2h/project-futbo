class_name Ball
extends Node3D

enum Mode {INERT, DRIBBLED}
var mode: Mode = Mode.INERT

# Internal references
@onready var state: StateChart = $State

# physics nodes
@onready var inert_node: InertNode = $InertNode
@onready var dribbled_node: CharacterBody3D = $DribbledNode

# controlled nodes
@onready var direction_ray: DirectionRay = $DirectionRay
@onready var sprite: Node3D = $SpriteContainer

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

# Dynamic properties
var direction_faced: Enums.Direction = Enums.Direction.RIGHT

var dribbler_id: int
var is_owned: bool = false

var dribble_time: float
var player_dribble_marker_position: Vector3
var player_velocity: Vector3
var dribble_rotation_speed: float
var dribble_velocity_offset: float
var ball_snap_velocity: float


#=======================================================
# STATES
#=======================================================

# inert state
#----------------------------------------
func _on_inert_state_physics_processing(delta: float) -> void:
	# transfer transform to other nodes
	direction_ray.position = inert_node.position
	sprite.transform = inert_node.transform
	
	# dribbled follows inert node
	dribbled_node.transform = inert_node.transform


# dribbled state
#----------------------------------------
func _on_dribbled_state_entered() -> void:
	# dribbled node collides, inert node does not
	dribbled_node.set_collision_layer_value(3, true)
	inert_node.set_collision_layer_value(3, false)
	
	# freeze the inert node
	inert_node.sleeping = true
	inert_node.set_freeze_enabled(true)
	
	# dribbled node takes ownership of transform
	dribbled_node.transform = inert_node.transform
	
	# set mode
	mode = Mode.DRIBBLED
	
	# set dribble time to 0
	dribble_time = 0.0


func _on_dribbled_state_physics_processing(delta: float) -> void:
	# Dribbling animation
	dribble_time += delta
	var a: float = player_dribble_marker_position.x
	var b: float = dribbled_node.global_position.x
	var dribble_marker_distance: float = abs(a - b)
	var dribble_marker_position_delta: float = (a - b)/dribble_marker_distance
	
	# Match player velocity
	dribbled_node.velocity.x = player_velocity.x
	if dribble_marker_distance > 0.05:
		dribbled_node.velocity.x += dribble_marker_position_delta * ball_snap_velocity
	
	# Use gravity when not touching the ground
	if not dribbled_node.is_on_floor():
		dribbled_node.velocity.y += gravity * delta
	
	# Compute colliding behavior
	dribbled_node.move_and_slide()
	
	# Ball spinning animation
	dribbled_node.rotation.z = -dribble_time * direction_faced * \
		 dribble_rotation_speed * PI
		
	# transfer transform to other nodes
	direction_ray.position = dribbled_node.position
	sprite.transform = dribbled_node.transform
		
	# inert node follows dribbled node
	inert_node.transform = dribbled_node.transform
	inert_node.linear_velocity = dribbled_node.velocity


func _on_dribbled_state_exited() -> void:
	dribbler_id = 0
	is_owned = false
	
		# wake up the inert node
	inert_node.set_freeze_enabled(false)
	inert_node.sleeping = false
	
	# inert node takes ownership of transform
	inert_node.set_transform_and_velocity(dribbled_node.global_transform, dribbled_node.velocity)
	dribbled_node.velocity = Vector3.ZERO
	
	# inert node collides, dribbled node does not
	inert_node.set_collision_layer_value(3, true)
	dribbled_node.set_collision_layer_value(3, false)
	
	# set mode
	mode = Mode.INERT


#=======================================================
# RECEIVED SIGNALS
#=======================================================
# Signals from player indicating which direction they're facing
func _on_facing_left() -> void:
	direction_faced = Enums.Direction.LEFT
	direction_ray.direction_faced = Enums.Direction.LEFT


func _on_facing_right() -> void:
	direction_faced = Enums.Direction.RIGHT
	direction_ray.direction_faced = Enums.Direction.RIGHT


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func impulse(force_vector: Vector3) -> void:
	end_dribbling()
	inert_node.set_impulse(force_vector)


func own(player_id: int) -> void:
	if not is_owned:
		dribbler_id = player_id
		is_owned = true


func disown(player_id: int) -> void:
	if dribbler_id == player_id:
		dribbler_id = 0
		is_owned = false


func start_dribbling() -> void:
	state.send_event("inert to dribbled")


func end_dribbling() -> void:
	state.send_event("dribbled to inert")


func get_control_node_position() -> Vector3:
	if mode == Mode.INERT:
		return inert_node.global_position
	else:
		return dribbled_node.global_position


func get_control_node_velocity() -> Vector3:
	if mode == Mode.INERT:
		return inert_node.linear_velocity
	else:
		return dribbled_node.velocity
