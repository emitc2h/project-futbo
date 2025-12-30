class_name DroneDiveAttackAction
extends BTAction

## Parameters
@export var target_velocity: float = 12.0
@export var acceleration: float = 60.0
@export var time_closed: float = 3.0

## Internal References
var drone: Drone
var signal_id: int
var open_at_end_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time_elapsed_closed: float

## Progress gates
var is_opening: bool
var is_open: bool
var is_defendable: bool
var targeting_disabled: bool
var engines_stopping: bool
var engines_are_off: bool
var has_stopped: bool
var proximity_detector_disabled: bool
var is_accelerating_up: bool
var is_done_accelerating_up: bool
var is_closing: bool
var is_closed: bool
var is_char_and_defendable_again: bool
var is_done_facing_target_at_end: bool
var is_facing_target_at_end: bool
var is_opening_at_end: bool
var is_open_at_end: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)
	drone.accelerate_finished.connect(_on_accelerate_finished)
	drone.quick_close_finished.connect(_on_quick_close_finished)
	drone.face_toward_finished.connect(_on_face_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	open_at_end_id = rng.randi()
	
	probe_initial_state()
	
	has_stopped = false
	is_accelerating_up = false
	is_done_accelerating_up = false
	is_closing = false
	is_closed = false
	is_char_and_defendable_again = false
	is_done_facing_target_at_end = false
	is_facing_target_at_end = false
	is_opening_at_end = false
	is_open_at_end = false
	
	time_elapsed_closed = 0.0


func _tick(delta: float) -> Status:
	if not is_defendable:
		drone.become_defendable()
		is_defendable = true
	
	if not is_open:
		if not is_opening:
			drone.open(signal_id)
			is_opening = true
	
	if not engines_are_off:
		if not engines_stopping:
			drone.stop_engines(signal_id)
			engines_stopping = true
	
	if not targeting_disabled:
		drone.disable_targeting()
		drone.disable_proximity_detector()
		targeting_disabled = true
	
	if not has_stopped:
		drone.stop_moving(delta)
		if abs(drone.physics_mode_states.left_right_axis) < 0.01:
			has_stopped = true
		return RUNNING

	if not is_done_accelerating_up:
		if not is_accelerating_up:
			var d: float = drone.targeting_states.target.global_position.x - drone.char_node.global_position.x
			var angle_of_reach: float = PI/4 + 0.5 * acos((12.0 * d)/(target_velocity * target_velocity))
			drone.accelerate(angle_of_reach, acceleration, target_velocity, signal_id)
			is_accelerating_up = true
		return RUNNING
	
	if not is_closed:
		if not is_closing:
			drone.become_invulnerable()
			drone.become_rigid()
			drone.quick_close(signal_id)
			is_closing = true
		return RUNNING
	
	if not time_elapsed_closed > time_closed:
		time_elapsed_closed += delta
		return RUNNING
	
	if not is_char_and_defendable_again:
		print_debug("drone become_char")
		drone.become_char()
		drone.become_defendable()
		drone.enable_proximity_detector()
		is_char_and_defendable_again = true
	
	if not is_open_at_end:
		if not is_opening_at_end:
			drone.open(open_at_end_id)
			is_opening_at_end = true
		return RUNNING
	
	if not is_done_facing_target_at_end:
		if not is_facing_target_at_end:
			drone.face_toward(drone.targeting_states.target.global_position.x, signal_id)
			is_facing_target_at_end = true
		return RUNNING
	
	print("enable_targeting after dive attack")
	drone.enable_targeting()
	print("done enabling targeting")
	
	return SUCCESS


func _exit() -> void:
	print("exiting drone_dive_attack_action")


##########################################
## UTILITIES                           ##
##########################################
func probe_initial_state() -> void:
	match(drone.engagement_mode_states.state):
		drone.engagement_mode_states.State.OPEN:
			is_open = true
			is_opening = false
		drone.engagement_mode_states.State.OPENING:
			is_open = false
			is_opening = true
		_:
			is_open = false
			is_opening = false
	
	match(drone.vulnerability_states.state):
		drone.vulnerability_states.State.DEFENDABLE:
			is_defendable = true
		_:
			is_defendable = false
	
	match(drone.engines_states.state):
		drone.engines_states.State.OFF:
			engines_are_off = true
			engines_stopping = false
		drone.engines_states.State.STOPPING:
			engines_are_off = false
			engines_stopping = true
		_:
			engines_are_off = false
			engines_stopping = false
	
	match(drone.proximity_states.state):
		drone.proximity_states.State.DISABLED:
			proximity_detector_disabled = true
		_:
			proximity_detector_disabled = false
	
	match(drone.targeting_states.state):
		drone.targeting_states.State.DISABLED:
			targeting_disabled = true
		_:
			targeting_disabled = false


##########################################
## SIGNALS                             ##
##########################################
func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_open = true
	if open_at_end_id == id:
		is_open_at_end = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		engines_are_off = true


func _on_accelerate_finished(id: int) -> void:
	drone.prepare_dive_impact()
	if signal_id == id:
		is_done_accelerating_up = true


func _on_quick_close_finished(id: int) -> void:
	if signal_id == id:
		is_closed = true


func _on_face_finished(id: int) -> void:
	if signal_id == id:
		is_done_facing_target_at_end = true
