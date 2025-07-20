class_name CloseAction
extends BTAction

@export var check_signal_id: bool
@export var async: bool

var drone: DroneV2
var done: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var signal_id: int

func _setup() -> void:
	drone = agent as DroneV2
	drone.close_finished.connect(_on_close_finished)


func _enter() -> void:
	done = false
	
	if drone.engagement_mode_states.state == drone.engagement_mode_states.State.CLOSED:
		done = true
	else:
		signal_id = rng.randi()
		drone.close(signal_id)
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
