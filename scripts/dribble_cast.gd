class_name DribbleCast
extends RayCast2D

# Nodes controlled by this node
@export var player_dribble_ability: PlayerDribbleAbility

# Internal references
@onready var state: StateChart = $State

# Dynamic properties
var tracked_ball: Ball2


#=======================================================
# UTILITY FUNCTIONS
#=======================================================
func hits_ball() -> bool:
	if self.is_colliding():
		match self.get_collider().name:
			"DribbledNode":
				return true
			"InertNode":
				return true
			_:
				return false
	else:
		return false


#=======================================================
# STATES
#=======================================================

# tracking state
#----------------------------------------
func _on_tracking_state_physics_processing(delta: float) -> void:
	self.target_position = tracked_ball.dribbled_node.global_position - self.global_position
	if not hits_ball():
		player_dribble_ability.end_dribble()


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func start_tracking(ball: Ball2) -> void:
	tracked_ball = ball
	state.send_event("idle to tracking")


func end_tracking() -> void:
	tracked_ball = null
	state.send_event("tracking to idle")
