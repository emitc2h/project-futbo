class_name PlayerKickAbility
extends Node3D

# Nodes controlled by this node
@export var player: Player

# Nodes controlled by this node
var player_asset: PlayerAsset

# Internal references
@onready var state: StateChart = $State
@onready var clamped_aim: ClampedAim = $ClampedAim
@onready var kickzone: Area3D = $KickZone

# Configurables
@export var kick_force: float = 7.0
@export var long_kick_force: float = 14.0

# Static/Internal properties
var kickzone_position_x: float
var player_id: int

# Dynamic properties
var aim: Vector2
var ball: Ball
var direction: Enums.Direction = Enums.Direction.RIGHT
var previous_sprite_animation: String
var is_sprinting: bool = false
var kick_button_is_pressed: bool = false

# State tracking
var is_in_ready_state: bool = false


# Record kickzone offset to flip the zone when the player faces left
func _ready() -> void:
	kickzone_position_x = kickzone.position.x
	player_asset = player.player_asset
	player_id = player.get_instance_id()


#=======================================================
# STATES
#=======================================================

# not ready state
#----------------------------------------
func _on_not_ready_state_entered() -> void:
	ball = null


func _on_not_ready_state_physics_processing(delta: float) -> void:
	if is_sprinting and kick_button_is_pressed:
		state.send_event("not ready to standby")


# standby state
#----------------------------------------
func _on_standby_state_physics_processing(delta: float) -> void:
	if not (is_sprinting and kick_button_is_pressed):
		state.send_event("standby to not ready")


# ready state
#----------------------------------------
func _on_ready_state_entered() -> void:
	# Sometimes the ball leaves the kickzone before the transition to not ready can be effected
	if kickzone.get_overlapping_bodies().is_empty():
		state.send_event("ready to not ready")
	is_in_ready_state = true


func _on_ready_state_exited() -> void:
	is_in_ready_state = false


# kick state
#----------------------------------------
func _on_kick_state_entered() -> void:
	ball.impulse(clamped_aim.get_vector(aim, direction) * kick_force)
	# if the kick doesn't work for some reason, stay in ready state
	# ready state will be dropped once the ball has exited the kick zone
	state.send_event("kick to ready")


func _on_kick_state_exited() -> void:
	player_asset.play(previous_sprite_animation)


# long kick state
#----------------------------------------
func _on_long_kick_state_entered() -> void:
	ball.impulse(Converters.vec3_from(Vector2(direction, -0.66).normalized()) * long_kick_force)
	state.send_event("long kick to standby")


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from KickZone
#----------------------------------------
func _on_kick_zone_body_entered(body: Node3D) -> void: 
	ball = body.get_parent() as Ball
	state.send_event("not ready to ready")
	state.send_event("standby to long kick")


func _on_kick_zone_body_exited(body: Node3D) -> void:
	ball = body.get_parent() as Ball
	# prevents ball from being unkickable while dribbling, even if it falls out of the kick zone
	if player_id != ball.dribbler_id:
		state.send_event("ready to not ready")


# from PlayerBasicMovement
#----------------------------------------
func _on_facing_left() -> void:
	direction = Enums.Direction.LEFT
	kickzone.position.x = -kickzone_position_x


func _on_facing_right() -> void:
	direction = Enums.Direction.RIGHT
	kickzone.position.x = kickzone_position_x


func _on_started_sprinting() -> void:
	is_sprinting = true


func _on_ended_sprinting() -> void:
	is_sprinting = false
	state.send_event("standby to not ready")


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func kick() -> void:
	# If the ball is already in the kick zone, kick it
	state.send_event("ready to kick")
	previous_sprite_animation = player_asset.animation
	player_asset.play("kick")


func kick_button_pressed() -> void:
	kick_button_is_pressed = true


func kick_button_released() -> void:
	kick_button_is_pressed = false
