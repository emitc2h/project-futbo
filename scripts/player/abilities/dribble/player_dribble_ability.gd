class_name PlayerDribbleAbility
extends Node3D

# Nodes controlled by this node
@export var player: Player
@export var enabled: bool = true

# Internal references
@onready var state: StateChart = $State
@onready var pickup_zone: Area3D = $PickupZone
@onready var dribble_marker: Marker3D = $DribbleMarker
@onready var dribble_cast: DribbleCast = $DribbleCast

# Static/Internal properties
var pickup_zone_position_x: float
var dribble_marker_position_x: float

# Dynamic properties
var ball: Ball
var player_id: int
var direction_faced: Enums.Direction = Enums.Direction.RIGHT

# State tracking
var is_ready: bool = false
var is_dribbling: bool = false


# Record PickupZone, DribbleMarker & DribbleCast position so they can be flipped
func _ready() -> void:
	Signals.facing_left.connect(_on_facing_left)
	Signals.facing_right.connect(_on_facing_right)
	Signals.player_knocked.connect(_on_player_knocked)
	pickup_zone_position_x = pickup_zone.position.x
	dribble_marker_position_x = dribble_marker.position.x
	player_id = player.get_instance_id()


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
	ball.own(player_id)
	
	# If the ball accepts ownership, start dribbling
	if player_id == ball.dribbler_id:
		ball.start_dribbling()
		
		#start tracking the ball with the DribbleCast
		dribble_cast.start_tracking(ball)
		is_dribbling = true
		player.is_dribbling = true
	else:
		state.send_event("dribbling to not ready")


func _on_dribbling_state_physics_processing(delta: float) -> void:
	if player_id == ball.dribbler_id:
		Signals.active_dribble_marker_position_updated.emit(dribble_marker.global_position)
		Signals.player_velocity_updated.emit(player.velocity)
	else:
		state.send_event("dribbling to not ready")


func _on_dribbling_state_exited() -> void:
	# if thhis player is indeed the dribbler, end dribbling and ownership
	if player_id == ball.dribbler_id:
		ball.end_dribbling()
		ball.disown(player_id)
		
	# stop tracking the ball with the DribbleCast
	dribble_cast.end_tracking(direction_faced)
	
	is_dribbling = false
	player.is_dribbling = false


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from PickupZone
#----------------------------------------
func _on_pickup_zone_body_entered(body: Node3D) -> void:
	ball = body.get_parent() as Ball
	state.send_event("not ready to ready")
	state.send_event("standby to dribbling")


func _on_pickup_zone_body_exited(body: Node3D) -> void:
	state.send_event("ready to not ready")


# from PlayerBasicMovement
#----------------------------------------
func _on_facing_left() -> void:
	pickup_zone.position.x = -pickup_zone_position_x
	dribble_marker.position.x = -dribble_marker_position_x
	direction_faced = Enums.Direction.LEFT


func _on_facing_right() -> void:
	pickup_zone.position.x = pickup_zone_position_x
	dribble_marker.position.x = dribble_marker_position_x
	direction_faced = Enums.Direction.RIGHT


# From globals
#----------------------------------------
func _on_player_knocked() -> void:
	end_dribble()


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func start_dribble() -> void:
	if not enabled:
		return
	if is_ready:
		state.send_event("ready to dribbling")
	else:
		state.send_event("not ready to standby")


func end_dribble() -> void:
	state.send_event("dribbling to ready")
	state.send_event("standby to not ready")


func ball_jump(jump_velocity_y: float) -> void:
	if ball and player_id == ball.dribbler_id:
		ball.physics_states.char_node.velocity.y += jump_velocity_y
