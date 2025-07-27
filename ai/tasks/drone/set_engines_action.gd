@tool
class_name SetEnginesAction
extends BTAction

const OFF: String = "off"
const THRUST: String = "thrust"
const BURST: String = "burst"
const STOP: String = "stop"
const QUICK_STOP: String = "quick stop"
const RESET_STOP: String = "reset stop"

@export_enum(THRUST, BURST, STOP, QUICK_STOP, RESET_STOP) var eng_type: String
@export var quick_stop_keep_speed: bool = false
@export var async: bool = true

var drone: Drone
var done: bool = false

func _generate_name() -> String:
	return "Set engines to " + eng_type


func _setup() -> void:
	drone = agent as Drone
	drone.stop_engines_finished.connect(_on_stop_engines_finished)
	done = false
	if async:
		done = true


func _tick(delta: float) -> Status:
	match(eng_type):
		THRUST:
			if drone.engines_states.state == drone.engines_states.State.THRUST:
				return SUCCESS
			drone.thrust()
		BURST:
			if drone.engines_states.state == drone.engines_states.State.BURST:
				return SUCCESS
			drone.burst()
		STOP:
			if drone.engines_states.state == drone.engines_states.State.OFF:
				return SUCCESS
			drone.stop_engines()
		QUICK_STOP:
			if drone.engines_states.state == drone.engines_states.State.OFF:
				return SUCCESS
			drone.quick_stop_engines(quick_stop_keep_speed)
		RESET_STOP:
			drone.reset_engines()
	if done:
		return SUCCESS
	return RUNNING


func _on_stop_engines_finished() -> void:
	done = true
