class_name AIController
extends Node2D

@export var ball_for_seeking: Ball
@export var home_goal: Goal
@export var away_goal: Goal

@export var seek_stop_distance: float
@export var goal_attempt_distance: float
@export var reset_distance: float

@onready var player: Player = $Player
@onready var player_state: StateChart = $Player/StateChart


var ball: Ball
var ball_state: StateChart

var is_dribbling: bool = false
var ball_is_kickable: bool = false


signal kick(kick_vector: Vector2)
signal headbutt(headbutt_vector: Vector2)


func _ready() -> void:
	## In order to know when the player actually scores
	away_goal.scored.connect(scored)
	#process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		$StateChart.send_event("attack_to_reset")
		$StateChart.send_event("seek_to_reset")
		$StateChart.send_event("celebrate_to_reset")
		$StateChart.send_event("defend_to_reset")


func _on_defend_state_entered() -> void:
	$PatrolTimer.start()
	$StateChart.send_event("idle_to_move_left")
	

func _on_patrol_timer_timeout() -> void:
	if sign(player.direction) == -1.0:
		$StateChart.send_event("move_left_to_move_right")
	elif sign(player.direction) == 1.0:
		$StateChart.send_event("move_right_to_move_left")
	$PatrolTimer.start()
	
	
func seek_target(target_global_position: Vector2) -> void:
	var direction_to_target: float = sign(target_global_position.x - player.global_position.x)
	if direction_to_target == 1.0:
		$StateChart.send_event("idle_to_move_right")
		$StateChart.send_event("move_left_to_move_right")
	elif direction_to_target == -1.0:
		$StateChart.send_event("idle_to_move_left")
		$StateChart.send_event("move_right_to_move_left")


func _on_seek_state_physics_processing(delta: float) -> void:
	if not ball_is_kickable:
		seek_target(ball_for_seeking.get_driver_node().global_position)
	else:
		$StateChart.send_event("move_left_to_idle")
		$StateChart.send_event("move_right_to_idle")
		$StateChart.send_event("seek_to_attack")


func dribble_ball_sync() -> void:
	if ball:
		ball.player_direction_faced = player.direction_faced
		ball.player_dribble_marker_position = $Player/DribbleMarker.global_position


func _on_attack_state_entered() -> void:
	if ball and ball_is_kickable and not ball.is_owned:
		print("AI STATE NO BALL TO DRIBBLE")
		$StateChart.send_event("no_ball_to_dribble")
	else:
		$StateChart.send_event("attack_to_seek")


func _on_attack_state_physics_processing(delta: float) -> void:
	var distance_to_goal: float = away_goal.global_position.x - player.global_position.x
	if abs(distance_to_goal) > goal_attempt_distance:
		seek_target(away_goal.global_position)
	else:
		$StateChart.send_event("dribble_to_kick")
		$StateChart.send_event("move_left_to_idle")
		$StateChart.send_event("move_right_to_idle")


func _on_player_did_jump(vy: float) -> void:
	if ball:
		ball.jump(vy)


func _on_player_started_dribbling() -> void:
	is_dribbling = true


func _on_player_ended_dribbling() -> void:
	is_dribbling = false
	print("AI disown ball ended dribbling")
	disown_ball(ball)


func _on_player_entered_kickzone(ball_ref: Ball) -> void:
	print("AI own ball entered kickzone")
	own_ball(ball_ref)
	ball_is_kickable = true
	if ball:
		ball.get_animated_sprite_2d().modulate = Color.RED


func _on_player_left_kickzone(ball_ref: Ball) -> void:
	ball_is_kickable = false
	ball_ref.get_animated_sprite_2d().modulate = Color.WHITE
	if not is_dribbling:
		print("AI disown ball left kickzone")
		disown_ball(ball_ref)


func _on_player_player_velocity(v: Vector2) -> void:
	ball.player_velocity = v


func _on_player_velocity_x(vx: float) -> void:
	ball.player_velocity_x = vx


func _on_player_lost_ball() -> void:
	if ball_state:
		ball_state.send_event("dribbled_to_inert")
	$StateChart.send_event("attack_to_seek")
	print("AI disown ball lost ball")
	disown_ball(ball)


func _on_idle_state_entered() -> void:
	player.direction = 0.0
	player_state.send_event("running_to_pre_idle")


func _on_move_left_state_entered() -> void:
	player.direction = -0.6
	player_state.send_event("pre_idle_to_running")
	player_state.send_event("idle_to_running")
	player_state.send_event("face_right_to_turn_left")


func _on_move_right_state_entered() -> void:
	player.direction = 0.6
	player_state.send_event("pre_idle_to_running")
	player_state.send_event("idle_to_running")
	player_state.send_event("face_left_to_turn_right")


func _on_dribble_state_entered() -> void:
	if ball and ball_state and not ball.is_owned:
		print("AI SET BALL AND PLAYER STATE TO DRIBBLE")
		player_state.send_event("can_kick_to_dribble")
		ball_state.send_event("inert_to_dribbled")
		dribble_ball_sync()
	else:
		$StateChart.send_event("dribble_to_no_ball")
		$StateChart.send_event("attack_to_seek")


func _on_dribble_state_physics_processing(delta: float) -> void:
	dribble_ball_sync()


func _on_kick_state_entered() -> void:
	# kick at 45 degrees
	var kick_vector: Vector2 = Vector2(player.direction_faced, -1.0).normalized()
	kick.emit(kick_vector * player.KICK_FORCE)
	player_state.send_event("dribble_to_kick")
	$StateChart.send_event("kick_to_no_ball")
	disown_ball(ball)
	
	
func scored() -> void:
	$StateChart.send_event("attack_to_celebrate")


func _on_celebrate_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		player.velocity.y = -200.0
		player.animated_sprite.play("celebrate")
	$StateChart.send_event("celebrate_to_reset")


func _on_reset_state_physics_processing(delta: float) -> void:
	var distance_to_goal: float = home_goal.global_position.x - player.global_position.x
	if abs(distance_to_goal) > reset_distance:
		seek_target(home_goal.global_position)
	else:
		$StateChart.send_event("move_left_to_idle")
		$StateChart.send_event("move_right_to_idle")
		$StateChart.send_event("reset_to_seek")


func own_ball(ball_ref: Ball) -> void:
	if not ball_ref.is_owned:
		print("AI successfully own ball")
		ball = ball_ref
		ball_state = ball.get_node("StateChart")
	else:
		print("AI fails to own ball")


func disown_ball(ball_ref: Ball) -> void:
	if ball and ball_state:
		ball = null
		ball_state = null


func _on_player_headbutt(force: Vector2) -> void:
	headbutt.emit(force)
