@tool
class_name IsObjectInProximityZoneCondition
extends BTCondition

const PLAYER: String = "Player"
const CONTROL_NODE: String = "Control Node"

var drone: Drone
@export_enum (PLAYER, CONTROL_NODE) var object_type: String
@export var is_not: bool = false

func _generate_name() -> String:
	var output_str: String = object_type + " is"
	if is_not:
		output_str += " not"
	output_str += " in proximity zone"
	return output_str


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	var test: bool = false
	match(object_type):
		PLAYER:
			test = drone.proximity_states.player_in_detector
		CONTROL_NODE:
			test = drone.proximity_states.control_node_in_detector
	
	if test != is_not:
		return SUCCESS
	else:
		return FAILURE
