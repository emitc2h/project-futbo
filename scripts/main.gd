extends Node

var score_home: int = 0
var score_away: int = 0


func _on_ready() -> void:
	$UI.set_score_left(score_home)
	$UI.set_score_right(score_away)


func _on_goal_left_scored() -> void:
	score_away += 1
	$UI.set_score_left(score_away)
	

func _on_goal_right_scored() -> void:
	score_home += 1
	$UI.set_score_right(score_home)
