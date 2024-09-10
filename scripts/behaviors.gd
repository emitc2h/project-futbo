class_name Behaviors
extends Node2D

# Internal references
@onready var state: StateChart = $State

# Controlled Node
var player: Player2

# Skills
@export var seek_skill: SeekSkill

# Observed Quantities
var player_position: Vector2
var player_velocity: Vector2

var ball_position: Vector2
var ball_velocity: Vector2

var home_goal_position: Vector2
var away_goal_position: Vector2


func initialize() -> void:
	seek_skill.player = player
	seek_skill.player_basic_movement = player.get_node("PlayerBasicMovement")

#=======================================================
# STATES
#=======================================================

# seek state
#----------------------------------------
func _on_seek_state_physics_processing(delta: float) -> void:
	seek_skill.seek_target(ball_position)
