class_name AI3D
extends Node3D

# Nodes observed
@export var player: Player3D
@export var ball: Ball3D
@export var home_goal: Goal3D
@export var away_goal: Goal3D

# Internal references
@onready var behaviors: Behaviors3D = $Behaviors


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
