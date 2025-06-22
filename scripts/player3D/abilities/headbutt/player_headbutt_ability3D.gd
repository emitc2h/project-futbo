class_name PlayerHeadbuttAbility3D
extends Node3D

# External references (player)
@export var player: Player3D

# Internal references
@onready var state: StateChart = $State
@onready var head: Head3D = $Head3D


# Configurables
@export var headbutt_force: float = 10.0
@export var ready_velocity_threshold: float = -1.0

# Dynamic properties
var is_ready: bool = false

#=======================================================
# STATES
#=======================================================

# not ready state
#----------------------------------------
func _on_not_ready_state_physics_processing(delta: float) -> void:
	if player.velocity.y >= ready_velocity_threshold and not player.is_on_floor():
		state.send_event("not ready to ready")


# ready state
#----------------------------------------
func _on_ready_state_entered() -> void:
	is_ready = true


func _on_ready_state_physics_processing(delta: float) -> void:
	var ball: Ball = head.scan_for_ball()
	if ball:
		ball.impulse(Vector3.UP * headbutt_force + Vector3.RIGHT * player.velocity.x)
		state.send_event("ready to headbutting")
	if player.is_on_floor() or player.velocity.y < ready_velocity_threshold:
		state.send_event("ready to not ready")


func _on_ready_state_exited() -> void:
	is_ready = false


# headbutting state
#----------------------------------------
func _on_headbutting_state_entered() -> void:
	state.send_event("headbutting to not ready")
