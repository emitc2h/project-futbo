extends Node

@export var home_goal: Goal
@export var away_goal: Goal
@export var player: Player
@export var ball: Ball

@export var seek_stop_distance: float
@export var goal_attempt_distance: float


func _on_defend_state_entered() -> void:
	$PatrolTimer.start()
	$Adversary.direction = 1.0
	$Adversary/StateChart.send_event("idle_to_running")
	

func _on_patrol_timer_timeout() -> void:
	if $Adversary.direction == 1.0:
		$Adversary/StateChart.send_event("face_right_to_turn_left")
		$Adversary.direction = -1.0
	elif $Adversary.direction == -1.0:
		$Adversary/StateChart.send_event("face_left_to_turn_right")
		$Adversary.direction = 1.0
	$PatrolTimer.start()


func _on_seek_state_physics_processing(delta: float) -> void:
	# Find out where the ball is
	var distance_to_ball: float = ball.get_driver_node().global_position.x - $Adversary.global_position.x
	if abs(distance_to_ball) > seek_stop_distance:
		var direction_to_ball: float = sign(distance_to_ball)
		$Adversary.direction = direction_to_ball
		$Adversary/StateChart.send_event("idle_to_running")
		if not $Adversary.is_running_forward():
			if direction_to_ball == 1.0:
				$Adversary/StateChart.send_event("face_left_to_turn_right")
			else:
				$Adversary/StateChart.send_event("face_right_to_turn_left")
	else:
		$Adversary/StateChart.send_event("running_to_pre_idle")
		$StateChart.send_event("seek_to_attack")


func dribble_ball_sync() -> void:
	ball.player_direction_faced = $Adversary.direction_faced
	ball.player_dribble_marker_position = $Adversary/DribbleMarker.global_position
	ball.player_velocity = $Adversary.velocity
	ball.player_velocity_x = $Adversary.velocity.x


func _on_attack_state_entered() -> void:
	$Adversary/StateChart.send_event("can_kick_to_dribble")
	ball.get_node("StateChart").send_event("kickable_to_dribbled")
	dribble_ball_sync()


func _on_attack_state_physics_processing(delta: float) -> void:
	dribble_ball_sync()
	var distance_to_goal: float = away_goal.global_position.x - $Adversary.global_position.x
	if abs(distance_to_goal) > goal_attempt_distance:
		var direction_to_goal: float = sign(distance_to_goal)
		$Adversary.direction = direction_to_goal
		$Adversary/StateChart.send_event("idle_to_running")
		if not $Adversary.is_running_forward():
			if direction_to_goal == 1.0:
				$Adversary/StateChart.send_event("face_left_to_turn_right")
			else:
				$Adversary/StateChart.send_event("face_right_to_turn_left")
	else:
		$Adversary/StateChart.send_event("dribble_to_kick")
		ball.get_node("StateChart").send_event("dribbled_to_kick")
		$StateChart.send_event("attack_to_defend")
