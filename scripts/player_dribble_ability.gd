class_name PlayerDribbleAbility
extends Node2D

# Nodes controlled by this node
@export var player: Player2

# Internal references
@onready var state: StateChart = $State
@onready var pickup_zone: Area2D = $PickupZone
@onready var dribble_marker: Marker2D = $DribbleMarker
@onready var dribble_cast: DribbleCast = $DribbleCast

# Configurables
@export var dribble_rotation_speed: float = 4.0
@export var dribble_velocity_offset: float = 0.63662
@export var ball_snap_velocity: float = 600.0

# Static/Internal properties
var pickup_zone_position_x: float
var dribble_marker_position_x: float

# Dynamic properties
var ball: Ball
var player_id: int
var direction_faced: Enums.Direction = Enums.Direction.RIGHT

# State tracking
var is_ready: bool = false


# Signals
signal own_ball(player_id: int)
signal release_ball(player_id: int)
signal player_dribbling(id: int,
	marker_position: Vector2, player_velocity: Vector2)


# Record PickupZone, DribbleMarker & DribbleCast position so they can be flipped
func _ready() -> void:
	pickup_zone_position_x = pickup_zone.position.x
	dribble_marker_position_x = dribble_marker.position.x


#=======================================================
# STATES
#=======================================================

# not ready state
#----------------------------------------
func _on_not_ready_state_entered() -> void:
	ball = null


# ready state
#----------------------------------------
func _on_ready_state_entered() -> void:
	is_ready = true


func _on_ready_state_exited() -> void:
	is_ready = false


# dribbling state
#----------------------------------------
func _on_dribbling_state_entered() -> void:
	# make the ball identify the player dribbling
	player_id = player.get_instance_id()
	ball.own(player_id)
	
	# If the ball accepts ownership, start dribbling
	if player_id == ball.dribbler_id:
		ball.start_dribbling()
		ball.dribble_rotation_speed = dribble_rotation_speed
		ball.dribble_velocity_offset = dribble_velocity_offset
		ball.ball_snap_velocity = ball_snap_velocity
		
		#start tracking the ball with the DribbleCast
		dribble_cast.start_tracking(ball)
	else:
		state.send_event("dribbling to not ready")


func _on_dribbling_state_physics_processing(delta: float) -> void:
	if player_id == ball.dribbler_id:
		ball.player_dribble_marker_position = dribble_marker.global_position
		ball.player_velocity = player.velocity
	else:
		state.send_event("dribbling to not ready")


func _on_dribbling_state_exited() -> void:
	# if thhis player is indeed the dribbler, end dribbling and ownership
	if player_id == ball.dribbler_id:
		ball.end_dribbling()
		ball.disown(player_id)
		
		# stop tracking the ball with the DribbleCast
		dribble_cast.end_tracking(direction_faced)


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from PickupZone
#----------------------------------------
func _on_pickup_zone_body_entered(body: Node2D) -> void:
	ball = body.get_parent()
	state.send_event("not ready to ready")
	state.send_event("standby to dribbling")


func _on_pickup_zone_body_exited(body: Node2D) -> void:
	state.send_event("ready to not ready")


# from PlayerBasicMovement
#----------------------------------------
func _on_facing_left() -> void:
	pickup_zone.position.x = -pickup_zone_position_x
	dribble_marker.position.x = -dribble_marker_position_x
	direction_faced = Enums.Direction.LEFT
	dribble_cast.face_left()


func _on_facing_right() -> void:
	pickup_zone.position.x = pickup_zone_position_x
	dribble_marker.position.x = dribble_marker_position_x
	direction_faced = Enums.Direction.RIGHT
	dribble_cast.face_right()


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func start_dribble() -> void:
	if is_ready:
		state.send_event("ready to dribbling")
	else:
		state.send_event("not ready to standby")


func end_dribble() -> void:
	state.send_event("dribbling to ready")
	state.send_event("standby to not ready")


func ball_jump(jump_velocity_y: float) -> void:
	if ball and player_id == ball.dribbler_id:
		ball.dribbled_node.velocity.y += jump_velocity_y




