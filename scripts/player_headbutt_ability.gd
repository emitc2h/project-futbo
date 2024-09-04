class_name PlayerHeadbuttAbility
extends Node2D

# External references (player)
@export var player: Player2

# Internal references
@onready var state: StateChart = $State

# Configurables
@export var headbutt_force: float = 1000.0

# Dynamic properties
var is_ready: bool = false

#=======================================================
# STATES
#=======================================================

# not ready state
#----------------------------------------
func _on_not_ready_state_physics_processing(delta: float) -> void:
	if player.velocity.y < 0.0 and not player.is_on_floor():
		state.send_event("not ready to ready")


# ready state
#----------------------------------------
func _on_ready_state_entered() -> void:
	is_ready = true


func _on_ready_state_physics_processing(delta: float) -> void:
	if player.is_on_floor() or player.velocity.y > 0.0:
		state.send_event("ready to not ready")


func _on_ready_state_exited() -> void:
	is_ready = false


# headbutting state
#----------------------------------------
func _on_headbutting_state_entered() -> void:
	state.send_event("headbutting to not ready")


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# from HeadbuttZone
#----------------------------------------
func _on_headbutt_zone_body_entered(body: Node2D) -> void:
	if is_ready:
		var ball: Ball = body.get_parent() as Ball
		ball.impulse(Vector2.UP * headbutt_force + Vector2.RIGHT * player.velocity.x)
		state.send_event("ready to headbutting")
