class_name DronePatrolAction
extends BTAction

## Parameters
@export var arrived_min_distance: float = 1.0
@export var pause_when_stopped_duration: float = 1.0

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var patrol_markers: Array[float]
var idx: int = 0
var time_elapsed_paused: float = 0.0

## Progress gates
var is_closing: bool
var is_closed: bool
var is_invulnerable: bool
var has_targeting_enabled: bool
var has_proximity_enabled: bool
var has_engines_stopped: bool
var has_engines_stopping: bool
var is_turning: bool
var is_facing_next_marker: bool
var stopped: bool
var pause: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	
	## Connect facing signals
	drone.face_toward_finished.connect(_on_face_toward_finished)
	drone.close_finished.connect(_on_close_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	## Register patrol markers
	patrol_markers.append(drone.repr.worldRepresentation.patrol_marker_1_pos)
	patrol_markers.append(drone.repr.worldRepresentation.patrol_marker_2_pos)
	
	## Start by going to the furthest marker to the drone
	idx = furthest_marker_idx()
	
	## Dynamic progress gates
	is_turning = false
	is_facing_next_marker = false
	stopped = false
	pause = true
	
	probe_initial_state()
	


func _tick(delta: float) -> Status:
	
	## Prepare the drone according to the measured initial state
	if not is_closed:
		if not is_closing:
			drone.close(signal_id)
			is_closing = true
	
	if not is_invulnerable:
		drone.become_invulnerable()
		is_invulnerable = true
	
	if not has_targeting_enabled:
		drone.enable_targeting()
		has_targeting_enabled = true
	
	if not has_proximity_enabled:
		drone.enable_proximity_detector()
		has_proximity_enabled = true
		
	if not has_engines_stopped:
		if not has_engines_stopping:
			drone.stop_engines(signal_id)
			has_engines_stopping = true
	
	## Make sure the drone is facing the marker it's going to
	if not is_facing_next_marker:
		if not is_turning:
			drone.face_toward(patrol_markers[idx], signal_id)
			is_turning = true
		return RUNNING
	
	## Once the drone faces the next patrol marker, reset the is_turning flag for the next loop
	is_turning = false
	
	var distance_to_marker: float = abs(drone.char_node.global_position.x - patrol_markers[idx])

	## If drone hasn't arrived, just keep moving
	if not distance_to_marker < arrived_min_distance:
		drone.move_toward_x_pos(patrol_markers[idx], delta)
		return RUNNING
	
	## If drone has arrived but not stopped, just keep on stopping
	if not stopped:
		drone.stop_moving(delta, 20.0)
		if abs(drone.char_node.velocity.length()) < 0.001:
			stopped = true
		else:
			return RUNNING
	
	## Take a pause after stopping (to maybe stop further?)
	if pause:
		if time_elapsed_paused < pause_when_stopped_duration:
			time_elapsed_paused += delta
			drone.stop_moving(delta, 40.0)
			return RUNNING
		else:
			pause = false
	
	## If the code made it this far, the drone is ready to go toward the next marker
	is_facing_next_marker = false
	stopped = false
	pause = true
	time_elapsed_paused = 0.0
	idx += 1
	idx %= patrol_markers.size()
	
	return RUNNING


##########################################
## UTILITIES                           ##
##########################################
func furthest_marker_idx() -> int:
	var drone_pos_x: float = drone.char_node.global_position.x
	var max_distance_found: float = 0.0
	var curr_max_idx: int = 0
	
	for i in patrol_markers.size():
		var curr_distance: float = abs(drone_pos_x - patrol_markers[i])
		if curr_distance > max_distance_found:
			curr_max_idx = i
			max_distance_found = curr_distance
	
	return curr_max_idx


func probe_initial_state() -> void:
	match(drone.engagement_mode_states.state):
		drone.engagement_mode_states.State.CLOSED, drone.engagement_mode_states.State.QUICK_CLOSE:
			is_closed = true
			is_closing = false
		drone.engagement_mode_states.State.CLOSING:
			is_closed = false
			is_closing = true
		_:
			is_closed = false
			is_closing = false
	
	match(drone.vulnerability_states.state):
		drone.vulnerability_states.State.INVULNERABLE:
			is_invulnerable = true
		_:
			is_invulnerable = false
	
	match(drone.targeting_states.state):
		drone.targeting_states.State.DISABLED:
			has_targeting_enabled = false
		_:
			has_targeting_enabled = true
	
	match(drone.proximity_states.state):
		drone.proximity_states.State.ENABLED:
			has_proximity_enabled = true
		drone.proximity_states.State.DISABLED:
			has_proximity_enabled = false
	
	match(drone.engines_states.state):
		drone.engines_states.State.OFF:
			has_engines_stopped = true
			has_engines_stopping = false
		drone.engines_states.State.STOPPING:
			has_engines_stopped = false
			has_engines_stopping = true
		_:
			has_engines_stopped = false
			has_engines_stopping = false


##########################################
## SIGNALS                             ##
##########################################
func _on_face_toward_finished(id: int) -> void:
	if signal_id == id:
		is_facing_next_marker = true


func _on_close_finished(id: int) -> void:
	if signal_id == id:
		is_closed = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		has_engines_stopped = true
