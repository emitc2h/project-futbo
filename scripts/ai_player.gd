class_name AI
extends Node2D

# Nodes observed
@export var player: Player2
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
	behaviors.ball_velocity = ball.get_control_mode_velocity()
