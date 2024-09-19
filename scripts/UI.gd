class_name Ui
extends CanvasLayer


func set_score_left(score: int) -> void:
	$ScoreLeft.text = str(score)
	

func set_score_right(score: int) -> void:
	$ScoreRight.text = str(score)
