class_name BallAttackAction
extends BTAction

@export var burst_duration: float

var drone: DroneV2
var turned_into_ball: bool
var become_rigid_done: bool
var closed_done: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var signal_id: int

var burst_time: float = 0.0

func _setup() -> void:
	drone = agent as DroneV2
	drone.quick_close_finished.connect(_on_quick_close_finished)
	drone.physics_mode_states.rigid_entered.connect(_on_become_rigid_finished)


func _enter() -> void:
	closed_done = false
	become_rigid_done = false
	drone.burst()
	burst_time = 0.0
	turned_into_ball = false
	signal_id = rng.randi()
	drone.disable_targeting()


func _tick(delta: float) -> Status:
	if burst_time < burst_duration:
		drone.move_toward_x_pos(drone.targeting_states.target.global_position.x, delta)
		burst_time += delta
	else:
		if not turned_into_ball:
			drone.become_rigid()
			drone.quick_close(signal_id)
			turned_into_ball = true
			
			if drone.physics_mode_states.state == drone.physics_mode_states.State.RIGID:
				become_rigid_done = true
			
			if drone.engagement_mode_states.state == drone.engagement_mode_states.State.CLOSED:
				closed_done = true
		
	if closed_done and become_rigid_done:
		return SUCCESS
	return RUNNING


func _on_quick_close_finished(id: int) -> void:
	if id == signal_id:
		closed_done = true


func _on_become_rigid_finished() -> void:
	become_rigid_done = true
