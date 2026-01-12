class_name RecordTotalCondition
extends DroneSuccessLearningBaseCondition

func _tick(_delta: float) -> Status:
	increment_record_total()
	return SUCCESS
