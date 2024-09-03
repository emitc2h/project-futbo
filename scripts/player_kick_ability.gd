class_name PlayerKickAbility
extends Node2D

# Nodes controlled by this node
@export var sprite: AnimatedSprite2D

# Internal references
@onready var state: StateChart = $State
@onready var clamped_aim: ClampedAim = $ClampedAim

# Configurables
@export var kick_force: float = 700.0

# Static/Internal properties
var kickzone_position_x: float

# Dynamic properties
var aim: Vector2
var ball: Ball2
var direction: Enums.Direction = Enums.Direction.RIGHT
var previous_sprite_animation: String

# State tracking
var is_ready: bool


# Record kickzone offset to flip the zone when the player faces left
func _ready() -> void:
	kickzone_position_x = self.position.x


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


# kicking state
#----------------------------------------
func _on_kicking_state_entered() -> void:
	ball.impulse(clamped_aim.get_vector(aim, direction) * kick_force)
	state.send_event("kicking to not ready")


func _on_kicking_state_exited() -> void:
	sprite.play(previous_sprite_animation)


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from KickZone
#----------------------------------------
func _on_kick_zone_body_entered(body: Node2D) -> void:
	ball = body.get_parent() as Ball2
	state.send_event("not ready to ready")


func _on_kick_zone_body_exited(body: Node2D) -> void:
	ball = body.get_parent() as Ball2
	# prevent ball from being unkickable while dribbling, even if it falls out of the kick zone
	if not ball.is_owned:
		state.send_event("ready to not ready")


# from PlayerBasicMovement
#----------------------------------------
func _on_facing_left() -> void:
	direction = Enums.Direction.LEFT
	self.position.x = -kickzone_position_x


func _on_facing_right() -> void:
	direction = Enums.Direction.RIGHT
	self.position.x = kickzone_position_x


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func kick() -> void:
	state.send_event("ready to kicking")
	previous_sprite_animation = sprite.animation
	sprite.play("kick")
