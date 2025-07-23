@tool
class_name SetTargetingAction
extends BTAction

const ENABLED: String = "enabled"
const DISABLED: String = "disabled"

@export_enum(ENABLED, DISABLED) var targ_type: String
@export var enable_to_acquiring: bool = false

var drone: Drone


func _generate_name() -> String:
	return "Set targeting to " + targ_type


func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	match(targ_type):
		ENABLED:
			drone.enable_targeting(enable_to_acquiring)
		DISABLED:
			drone.disable_targeting()
	return SUCCESS
