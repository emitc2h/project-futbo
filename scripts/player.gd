class_name Player
extends CharacterBody3D

# Nodes controlled by this node
@export var sprite: AnimatedSprite3D

# Dynamic properties
var can_run_backward: bool = false

# signals
signal facing_left()
signal facing_right()

signal display_stamina(color: Color)
signal hide_stamina()
signal update_stamina_value(value: float)

# Basic movement configurable properties
@export var sprint_velocity: float
@export var recovery_velocity: float
@export var stamina_limit: float = 2.0
@export var stamina_replenish_rate: float = 0.666

@export var run_forward_velocity: float
@export var run_backward_velocity: float
@export var run_deceleration: float
@export var jump_momentum: float

@onready var player_basic_movement: PlayerBasicMovement = $PlayerBasicMovement


#=======================================================
# RECEIVED SIGNALS
#=======================================================

# Signal transmission from abilities
func _on_facing_left() -> void:
	facing_left.emit()


func _on_facing_right() -> void:
	facing_right.emit()


func _on_display_stamina(color: Color) -> void:
	display_stamina.emit(color)


func _on_hide_stamina() -> void:
	hide_stamina.emit()


func _on_update_stamina_value(value: float) -> void:
	update_stamina_value.emit(value)


#=======================================================
# CONTROLS
#=======================================================
func run(direction: float) -> void:
	player_basic_movement.run(direction)


func stop() -> void:
	player_basic_movement.stop()


func jump() -> void:
	player_basic_movement.jump()
