class_name Behaviors
extends Node2D

# Internal references
@onready var state: StateChart = $State
@onready var celebration_timer: Timer = $CelebrationTimer

# Controlled Node
var player: Player

# Skills
@export var seek_skill: SeekSkill
@export var dribble_skill: DribbleSkill
@export var kick_skill: KickSkill
@export var jump_skill: JumpSkill

# Observed Quantities
var ball_position: Vector2
var ball_velocity: Vector2

var home_goal_position: Vector2
var away_goal_position: Vector2

# Constants
const GOAL_ATTEMPT_DISTANCE: float = 400.0
const RESET_DISTANCE: float = 500.0


func initialize() -> void:
	seek_skill.player = player
	seek_skill.basic_movement = player.get_node("PlayerBasicMovement")
	
	dribble_skill.player = player
	dribble_skill.dribble_ability = player.get_node("PlayerDribbleAbility")
	
	kick_skill.player = player
	kick_skill.kick_ability = player.get_node("PlayerKickAbility")
	
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
	if not dribble_skill.start_dribbling():
		state.send_event("attack to seek")


func _on_attack_state_physics_processing(delta: float) -> void:
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
	

#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func celebrate() -> void:
	state.send_event("idle to celebrate")
