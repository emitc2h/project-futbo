class_name Player
extends CharacterBody3D

# Nodes controlled by this node
@export var sprite: AnimatedSprite3D

# Dynamic properties
var can_run_backward: bool = false

# signals
signal facing_left()
signal facing_right()

# Basic movement configurable properties
@export var sprint_velocity: float
@export var recovery_velocity: float
@export var run_forward_velocity: float
@export var run_backward_velocity: float
@export var run_deceleration: float
@export var jump_momentum: float


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# Signal transmission from abilities
func _on_facing_left() -> void:
	facing_left.emit()


func _on_facing_right() -> void:
	facing_right.emit()
