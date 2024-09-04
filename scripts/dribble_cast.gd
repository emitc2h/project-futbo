class_name DribbleCast
extends RayCast2D

# Nodes controlled by this node
@export var player_dribble_ability: PlayerDribbleAbility

# Internal references
@onready var state: StateChart = $State

# Static/Internal properties
var init_target_pos: Vector2

# Dynamic properties
var tracked_ball: Ball
var is_tracking: bool = false


func _ready() -> void:
	init_target_pos = self.target_position


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
func _on_tracking_state_entered() -> void:
	is_tracking = true


func _on_tracking_state_physics_processing(delta: float) -> void:
	self.target_position = tracked_ball.dribbled_node.global_position - self.global_position
	if not hits_ball():
		player_dribble_ability.end_dribble()


func _on_tracking_state_exited() -> void:
	is_tracking = false


#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func start_tracking(ball: Ball) -> void:
	tracked_ball = ball
	state.send_event("idle to tracking")


func end_tracking(direction_faced: Enums.Direction) -> void:
	tracked_ball = null
	state.send_event("tracking to idle")
	if direction_faced == Enums.Direction.LEFT:
		self.target_position = -init_target_pos
	else:
		self.target_position = init_target_pos


func face_left() -> void:
	if not is_tracking:
		self.target_position.x = -init_target_pos.x


func face_right() -> void:
	if not is_tracking:
		self.target_position.x = init_target_pos.x


