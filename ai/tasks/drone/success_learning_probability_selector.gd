class_name DroneSuccessLearningProbabilitySelector
extends BTProbabilitySelector

@export var record_names: Array[String]
@export var printout: bool

func _setup() -> void:
	## Initialize blackboard record variables
	for record_name in record_names:
		blackboard.set_var(record_name + "_success_count", 1)
		blackboard.set_var(record_name + "_total_count", 1)


func _enter() -> void:
	if printout:
		print("===============================")
	for i in record_names.size():
		var record_name: String = record_names[i]
		var numerator: int = blackboard.get_var(record_name + "_success_count")
		var denominator: int = blackboard.get_var(record_name + "_total_count")
		var success_rate: float
		if denominator > 0:
			success_rate = float(numerator) / float(denominator)
		else:
			success_rate = 1.0 / record_names.size()
		
		if printout:
			print(record_name, " success rate: ", numerator, "/", denominator, " = ", success_rate)
		
		set_weight(i, success_rate)
	
	if printout:
		for i in record_names.size():
			print("probability for ", record_names[i], ": ", get_probability(i))
