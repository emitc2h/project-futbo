extends Node

@export var home_goal: Goal
@export var away_goal: Goal
@export var player: Player
@export var ball: Ball


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
