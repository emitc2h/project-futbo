@tool
class_name IsObjectInProximityZoneCondition
extends BTCondition

const PLAYER: String = "Player"
const CONTROL_NODE: String = "Control Node"

var drone: Drone
@export_enum (PLAYER, CONTROL_NODE) var object_type: String

func _generate_name() -> String:
	return object_type + " is in proximity zone"


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	match(object_type):
		PLAYER:
			if drone.proximity_states.player_in_detector:
				return SUCCESS
			else:
				return FAILURE
		CONTROL_NODE:
			if drone.proximity_states.control_node_in_detector:
				return SUCCESS
			else:
				return FAILURE
		_:
			return FAILURE
