class_name DiveAttackJumpAction
extends BTAction

@export_group("Parameters")
@export var target_velocity: float = 12.0
@export var acceleration: float = 60.0

var drone: Drone
var acceleration_done: bool
var done: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var signal_id: int

func _setup() -> void:
	drone = agent as Drone
	drone.accelerate_finished.connect(_on_accelerate_finished)
	drone.quick_close_finished.connect(_on_quick_close_finished)


func _enter() -> void:
	acceleration_done = false
	done = false
	signal_id = rng.randi()
	var d: float = drone.targeting_states.target.global_position.x - drone.char_node.global_position.x
	var angle_of_reach: float = PI/4 + 0.5 * acos((12.0 * d)/(target_velocity * target_velocity))
	drone.accelerate(angle_of_reach, acceleration, target_velocity, signal_id)


func _tick(_delta: float) -> Status:
	if acceleration_done:
		drone.become_rigid()
		drone.quick_close(signal_id)
		drone.quick_stop_engines(true)
	
	if done:
		return SUCCESS
	return RUNNING
	

func _on_accelerate_finished(id: int) -> void:
	drone.prepare_shockwave()
	if signal_id == id:
		acceleration_done = true


func _on_quick_close_finished(id: int) -> void:
	if signal_id == id:
		done = true
