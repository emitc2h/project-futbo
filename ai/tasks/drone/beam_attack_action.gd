class_name BeamAttackAction
extends BTAction

@export_group("Parameters")
@export var check_signal_id: bool
@export var async: bool

var drone: Drone
var done: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var signal_id: int


func _setup() -> void:
	drone = agent as Drone
	drone.fire_finished.connect(_on_fire_finished)


func _enter() -> void:
	done = false
	signal_id = rng.randi()
	drone.fire(signal_id)
	if async:
		done = true


func _tick(delta: float) -> Status:
	if done:
		return SUCCESS
	return RUNNING


func _on_fire_finished(id: int) -> void:
	if check_signal_id:
		if id == signal_id:
			done = true
	else:
		done = true
