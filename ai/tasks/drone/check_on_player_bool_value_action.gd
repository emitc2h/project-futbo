@tool
class_name CheckOnPlayerBoolValueAction
extends BTAction

var drone: Drone

const DRIBBLING: String = "dribbling"
@export_enum(DRIBBLING) var var_type: String
@export var is_not: bool = false


func _setup() -> void:
	drone = agent as Drone


func _generate_name() -> String:
	var name: String = "Check if player is "
	if is_not:
		name += "not "
	name += var_type
	return name


func _tick(_delta: float) -> Status:
	var test_value: float
	match(var_type):
		DRIBBLING:
			test_value = drone.repr.playerRepresentation.player_is_dribbling
	
	if is_not:
		test_value = !test_value
	
	if test_value:
		return SUCCESS
	else:
		return FAILURE
	
