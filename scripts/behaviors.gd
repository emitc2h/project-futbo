class_name Behaviors
extends Node3D

# Internal references
@onready var state: StateChart = $State
@onready var celebration_timer: Timer = $CelebrationTimer
@onready var idle_timer: Timer = $IdleTimer

# Controlled Node
var player: Player

# Skills
@export var seek_skill: SeekSkill
@export var dribble_skill: DribbleSkill
@export var kick_skill: KickSkill
@export var jump_skill: JumpSkill

# Disable controls for cut scenes
var _enabled: bool = true
@export var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		if not value:
			state.send_event("seek to disabled")
			state.send_event("attack to disabled")
			state.send_event("celebrate to disabled")
			state.send_event("reset to disabled")
			state.send_event("confused to disabled")
			state.send_event("idle to disabled")
		else:
			state.send_event("disabled to idle")

# Observed Quantities
var ball_position: Vector3
var ball_velocity: Vector3

var home_goal_position: Vector3
var away_goal_position: Vector3

# Constants
const GOAL_ATTEMPT_DISTANCE: float = 4.0
const RESET_DISTANCE: float = 5.0
const ODDS_OF_STEALING: float = 0.5


func initialize() -> void:
	seek_skill.player = player
	seek_skill.basic_movement = player.get_node("PlayerBasicMovement")
	
	dribble_skill.player = player
	dribble_skill.dribble_ability = player.get_node("PlayerDribbleAbility")
	
	kick_skill.player = player
	kick_skill.kick_ability = player.get_node("PlayerKickAbility")
	kick_skill.basic_movement = player.get_node("PlayerBasicMovement")
	
	jump_skill.player = player
	jump_skill.basic_movement = player.get_node("PlayerBasicMovement")

#=======================================================
# STATES
#=======================================================

# seek state
#----------------------------------------
func _on_seek_state_physics_processing(delta: float) -> void:
	if not dribble_skill.dribble_ability.is_ready:
		seek_skill.seek_target(ball_position)
	else:
		state.send_event("seek to attack")


# attack state
#----------------------------------------
func _on_attack_state_entered() -> void:
	# If dribbling attempt is unsuccessful, return to seek state
	dribble_skill.start_dribbling()
	if not dribble_skill.dribble_ability.is_dribbling:
		# If dribbling missed, this means another player has the ball
		# Try to kick
		var roll: float = randf()
		if roll > ODDS_OF_STEALING:
			kick_skill.kick_where_faced(0.5)
		# If kick fails, go back to seeking
		else:
			state.send_event("attack to seek")


func _on_attack_state_physics_processing(delta: float) -> void:
	# If the ball was lost
	if not dribble_skill.dribble_ability.is_dribbling:
		state.send_event("attack to confused")
	
	# Head toward the away goal
	var distance_to_away_goal: float = CalcPhys.distance_x_positions(
		player.global_position, away_goal_position)
	if distance_to_away_goal > GOAL_ATTEMPT_DISTANCE:
		seek_skill.seek_target(away_goal_position)
	# Aim for the goal and kick
	else:
		seek_skill.stop_seeking()
		var dir: float = CalcPhys.direction_x_positions(
			player.global_position, away_goal_position)
		# Construct an aim vector at 45 degrees toward the goal
		kick_skill.kick(Vector2(dir, -1.0))
		dribble_skill.end_dribbling()
		state.send_event("attack to idle")


# celebrate state
#----------------------------------------
func _on_celebrate_state_entered() -> void:
	celebration_timer.start()
	
	
func _on_celebrate_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		jump_skill.celebration_jump()


func _on_celebration_timer_timeout() -> void:
	state.send_event("celebrate to reset")
	celebration_timer.stop()


# reset state
#----------------------------------------
func _on_reset_state_physics_processing(delta: float) -> void:
	var distance_to_home_goal: float = CalcPhys.distance_x_positions(
		player.global_position, home_goal_position)
	if distance_to_home_goal > RESET_DISTANCE:
		seek_skill.seek_target(home_goal_position)
	else:
		state.send_event("reset to seek")


# reset state
#----------------------------------------
func _on_idle_state_entered() -> void:
	idle_timer.start()


func _on_idle_timer_timeout() -> void:
	state.send_event("idle to reset")
	idle_timer.stop()


# confused state
#----------------------------------------
func _on_confused_state_entered() -> void:
	seek_skill.stop_seeking()
	seek_skill.basic_movement.idle_with_custom_animation("confused")
	state.send_event("confused to seek")


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	player.stop()
	

#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func celebrate() -> void:
	state.send_event("idle to celebrate")
