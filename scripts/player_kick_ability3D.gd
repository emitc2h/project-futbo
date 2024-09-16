class_name PlayerKickAbility3D
extends Node3D

# Nodes controlled by this node
@export var player: Player3D

# Nodes controlled by this node
var sprite: AnimatedSprite3D

# Internal references
@onready var state: StateChart = $State
@onready var clamped_aim: ClampedAim3D = $ClampedAim
@onready var kickzone: Area3D = $KickZone

# Configurables
@export var kick_force: float = 7.0

# Static/Internal properties
var kickzone_position_x: float
var player_id: int

# Dynamic properties
var aim: Vector2
var ball: Ball3D
var direction: Enums.Direction = Enums.Direction.RIGHT
var previous_sprite_animation: String

# State tracking
var is_ready: bool


# Record kickzone offset to flip the zone when the player faces left
func _ready() -> void:
	kickzone_position_x = kickzone.position.x
	sprite = player.sprite
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
	# Sometimes the ball leaves the kickzone before the transition to not ready can be effected
	if kickzone.get_overlapping_bodies().is_empty():
		state.send_event("ready to not ready")
	is_ready = true


func _on_ready_state_exited() -> void:
	is_ready = false


# kicking state
#----------------------------------------
func _on_kicking_state_entered() -> void:
	ball.impulse(clamped_aim.get_vector(aim, direction) * kick_force)
	# if the kick doesn't work for some reason, stay in ready state
	# ready state will be dropped once the ball has exited the kick zone
	state.send_event("kicking to ready")


func _on_kicking_state_exited() -> void:
	sprite.play(previous_sprite_animation)


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from KickZone
#----------------------------------------
func _on_kick_zone_body_entered(body: Node3D) -> void: 
	ball = body.get_parent() as Ball3D
	state.send_event("not ready to ready")


func _on_kick_zone_body_exited(body: Node3D) -> void:
	ball = body.get_parent() as Ball3D
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


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func kick() -> void:
	state.send_event("ready to kicking")
	previous_sprite_animation = sprite.animation
	sprite.play("kick")
