class_name AI
extends Node3D

# Nodes observed
@export var player: Player
@export var ball: Ball
@export var home_goal: Goal
@export var away_goal: Goal

# Internal references
@onready var behaviors: Behaviors = $Behaviors


func _ready() -> void:
	behaviors.home_goal_position = home_goal.global_position
	behaviors.away_goal_position = away_goal.global_position
	behaviors.player = player
	behaviors.initialize()


func _physics_process(delta: float) -> void:
	behaviors.ball_position = ball.get_control_node_position()
	behaviors.ball_velocity = ball.get_control_node_velocity()


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_away_scored() -> void:
	behaviors.celebrate()
