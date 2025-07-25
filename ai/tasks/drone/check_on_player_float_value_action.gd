@tool
class_name CheckOnPlayerFloatValueAction
extends BTAction

var drone: Drone

const X_POSITION: String = "x position"
const X_DISTANCE: String = "x distance"
@export_enum(X_POSITION, X_DISTANCE) var var_type: String

const EQUAL_TO: String = "equal to"
const GREATER_THAN: String = "greater than"
const LESSER_THAN: String = "lesser than"
const NEAR: String = "near"
@export_enum(EQUAL_TO, GREATER_THAN, LESSER_THAN, NEAR) var operator_type: String
@export var value: float
@export var tolerance: float


func _setup() -> void:
	drone = agent as Drone


func _generate_name() -> String:
	var name: String = ""
	name += "Check that player " + var_type + " is " + operator_type + " " + str(value)
	if operator_type == NEAR:
		name += " +- " + str(tolerance)
	return name


func _tick(delta: float) -> Status:
	var test_value: float
	match(var_type):
		X_POSITION:
			test_value = drone.repr.playerRepresentation.last_known_player_pos_x
		X_DISTANCE:
			test_value = abs(drone.get_global_pos_x() - drone.repr.playerRepresentation.last_known_player_pos_x)
	
	var test: bool
	match(operator_type):
		EQUAL_TO:
			test = (test_value == value)
		GREATER_THAN:
			test = (test_value > value)
		LESSER_THAN:
			test = (test_value < value)
		NEAR:
			test = ((test_value < value + tolerance) and (test_value > value - tolerance))
	
	if test:
		return SUCCESS
	else:
		return FAILURE
	
