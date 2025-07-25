@tool
class_name SetProximityAction
extends BTAction

const ENABLED: String = "enabled"
const DISABLED: String = "disabled"

@export_enum(ENABLED, DISABLED) var state_type: String

var drone: Drone


func _generate_name() -> String:
	return "Set proximity detector to " + state_type


func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	match(state_type):
		ENABLED:
			if drone.proximity_states.state == drone.proximity_states.State.ENABLED:
				return SUCCESS
			drone.enable_proximity_detector()
		DISABLED:
			if drone.proximity_states.state == drone.proximity_states.State.DISABLED:
				return SUCCESS
			drone.disable_proximity_detector()
	return SUCCESS
