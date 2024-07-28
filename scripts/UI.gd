class_name Ui
extends CanvasLayer


func set_score_red(score: int) -> void:
	$ScoreRed.text = "Score: " + str(score)
	

func set_score_blue(score: int) -> void:
	$ScoreBlue.text = "Score: " + str(score)
