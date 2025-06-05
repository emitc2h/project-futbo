class_name Player3D
extends CharacterBody3D

# Nodes controlled by this node
@export var asset: CharacterAsset

# Dynamic properties
var can_run_backward: bool = false

# Basic movement configurable properties
@export_group("Basic Movement Properties")
@export var sprint_velocity: float = 7.0
@export var recovery_velocity: float = 4.0
@export var stamina_limit: float = 2.0
@export var stamina_replenish_rate: float = 0.666

@export var run_forward_velocity: float = 5.0
@export var run_backward_velocity: float = 3.5
@export var run_deceleration: float = 0.4
@export var jump_momentum: float = 3.6

@onready var player_basic_movement: PlayerBasicMovement3D = $PlayerBasicMovement3D

# Animation handles
@export_group("Animation Handles")
@export var left_right_axis: float:
	get:
		if player_basic_movement:
			return player_basic_movement.left_right_axis
		else:
			return 0.0
	set(value):
		run(value)


#=======================================================
# CONTROLS
#=======================================================
func run(direction: float) -> void:
	if player_basic_movement:
		player_basic_movement.run(direction)


func stop() -> void:
	if player_basic_movement:
		player_basic_movement.stop()


func jump() -> void:
	if player_basic_movement:
		player_basic_movement.jump()


func get_on_path(path: CharacterPath) -> void:
	player_basic_movement.get_on_path(path)


func get_off_path() -> void:
	player_basic_movement.get_off_path()
