@tool
class_name CloseAction
extends BTAction

@export_group("Parameters")
@export var check_signal_id: bool
@export var async: bool
@export var quick: bool
@export var stop_engines: bool

var drone: Drone
var done: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var signal_id: int


func _generate_name() -> String:
	if quick:
		return "Quick Close"
	else:
		return "Close"


func _setup() -> void:
	drone = agent as Drone
	if quick:
		drone.quick_close_finished.connect(_on_quick_close_finished)
	else:
		drone.close_finished.connect(_on_close_finished)


func _enter() -> void:
	done = false
	
	if drone.engagement_mode_states.state == drone.engagement_mode_states.State.CLOSED:
		done = true
	else:
		signal_id = rng.randi()
		if quick:
			drone.quick_close(signal_id)
			if stop_engines:
				drone.stop_engines()
		else:
			drone.close(signal_id)
			if stop_engines:
				drone.quick_stop_engines()
		if async:
			done = true


func _tick(delta: float) -> Status:
	if done:
		return SUCCESS
	return RUNNING
	

func _on_close_finished(id: int) -> void:
	if check_signal_id:
		if id == signal_id:
			done = true
	else:
		done = true


func _on_quick_close_finished(id: int) -> void:
	if check_signal_id:
		if id == signal_id:
			done = true
	else:
		done = true
