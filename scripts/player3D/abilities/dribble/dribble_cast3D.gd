class_name DribbleCast3D
extends RayCast3D

# Nodes controlled by this node
@export var player_dribble_ability: PlayerDribbleAbility3D

# Internal references
@onready var state: StateChart = $State

# Static/Internal properties
var init_target_pos: Vector3

# Dynamic properties
var tracked_ball: Ball
var is_tracking: bool = false


func _ready() -> void:
	init_target_pos = self.target_position
	Signals.facing_left.connect(_on_facing_left)
	Signals.facing_right.connect(_on_facing_right)


#=======================================================
# STATES
#=======================================================

# tracking state
#----------------------------------------
func _on_tracking_state_entered() -> void:
	is_tracking = true


func _on_tracking_state_physics_processing(delta: float) -> void:
	self.target_position = tracked_ball.get_ball_position() - self.global_position

	self.force_update_transform()
	self.force_raycast_update()
	
	if not CastUtils.hits_ball(self):
		pass
		#player_dribble_ability.end_dribble()


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


func _on_facing_left() -> void:
	if not is_tracking:
		self.target_position.x = -init_target_pos.x


func _on_facing_right() -> void:
	if not is_tracking:
		self.target_position.x = init_target_pos.x
