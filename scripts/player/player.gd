class_name Player
extends CharacterBody3D

# Nodes controlled by this node
@export var player_asset: PlayerAsset

# Dynamic properties
var can_run_backward: bool = false

# signals
signal facing_left()
signal facing_right()

signal display_stamina(color: Color)
signal hide_stamina()
signal update_stamina_value(value: float)

# Basic movement configurable properties
@export_group("Basic Movement Properties")
@export var sprint_velocity: float
@export var recovery_velocity: float
@export var stamina_limit: float = 2.0
@export var stamina_replenish_rate: float = 0.666

@export var run_forward_velocity: float
@export var run_backward_velocity: float
@export var run_deceleration: float
@export var jump_momentum: float

@onready var player_basic_movement: PlayerBasicMovement = $PlayerBasicMovement

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

@export var play_animation: String:
	get:
		return ""
	set(value):
		if player_asset:
			player_asset.play(value)


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
