extends Node

var score_red: int = 0
var score_blue: int = 0


func _on_ready() -> void:
	$UI.set_score_red(score_red)
	$UI.set_score_blue(score_blue)


func _on_goal_red_scored() -> void:
	score_red += 1
	$UI.set_score_red(score_red)
	

func _on_goal_blue_scored() -> void:
	score_blue += 1
	$UI.set_score_blue(score_blue)
