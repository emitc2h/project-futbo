@tool
class_name IsPreviousAttackCondition
extends BTCondition

var drone: Drone

@export_enum(
	drone.behavior_attack2_states.ACTION_TRACK,
	drone.behavior_attack2_states.ACTION_RAM_ATTACK,
	drone.behavior_attack2_states.ACTION_BEAM_ATTACK,
	drone.behavior_attack2_states.ACTION_DIVE_ATTACK) var previous_action: String

@export var is_not: bool

func _generate_name() -> String:
	var name: String = "Check that previous attack is "
	if is_not:
		name += "not "
	name += previous_action
	return name


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	var check: bool = drone.behavior_attack2_states.previous_chosen_attack == previous_action
	if is_not:
		check = !check
	
	if check:
		return SUCCESS
	else:
		return FAILURE
