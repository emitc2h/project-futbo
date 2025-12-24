class_name MeasureSuccessCondition
extends DroneSuccessLearningBaseCondition

@export_enum(
	player_repr_is_dribbling,
	player_repr_is_dead,
	player_repr_shield_charges,
	control_node_repr_power_on,
	control_node_repr_charges,
	control_node_repr_shield_expanded
) var success_measure: String


func _tick(_delta: float) -> Status:
	increment_record_total()
	match(success_measure):
		player_repr_is_dribbling:
			if not blackboard.get_var(INTERNAL + player_repr_is_dribbling) as bool:
				increment_record_success()
			return SUCCESS
		
		player_repr_is_dead:
			if blackboard.get_var(INTERNAL + player_repr_is_dead) as bool:
				increment_record_success()
			return SUCCESS
		
		player_repr_shield_charges:
			var curr_charge: int = blackboard.get_var(INTERNAL + player_repr_shield_charges)
			var prev_charge: int = blackboard.get_var(SUCCESS_BUFFER + player_repr_shield_charges)
			if curr_charge < prev_charge:
				increment_record_success()
			return SUCCESS
		
		control_node_repr_power_on:
			if not blackboard.get_var(INTERNAL + control_node_repr_power_on) as bool:
				increment_record_success()
			return SUCCESS
		
		control_node_repr_charges:
			var curr_charge: int = blackboard.get_var(INTERNAL + control_node_repr_charges)
			var prev_charge: int = blackboard.get_var(SUCCESS_BUFFER + control_node_repr_charges)
			if curr_charge < prev_charge:
				increment_record_success()
			return SUCCESS
		
		control_node_repr_shield_expanded:
			if not blackboard.get_var(INTERNAL + control_node_repr_shield_expanded) as bool:
				increment_record_success()
			return SUCCESS
		
		_:
			return SUCCESS


func increment_record_success() -> void:
	var current_value_success: int = blackboard.get_var(record_name + "_success_count") as int
	blackboard.set_var(record_name + "_success_count", current_value_success + 1)


func increment_record_total() -> void:
	var current_value_total: int = blackboard.get_var(record_name + "_total_count") as int
	blackboard.set_var(record_name + "_total_count", current_value_total + 1)
