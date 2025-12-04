class_name DronePatrolAction
extends BTAction

@export var burst_min_distance: float = 18.0
@export var thrust_min_distance: float = 8.0
@export var arrived_min_distance: float = 0.1
@export var pause_when_stopped_duration: float = 0.0


var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var patrol_markers: Array[float]
var idx: int = 0

var facing_finished: bool
var engines_stopping: bool
var engines_stopped: bool
var is_closed: bool
var arrived: bool
var stopped: bool
var pause: bool

var time_elapsed_paused: float = 0.0

func _setup() -> void:
	drone = agent as Drone
	
	## Connect facing signals
	drone.face_toward_finished.connect(_on_face_toward_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)
	drone.close_finished.connect(_on_close_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	## Prepare the drone state
	prepare()
	
	## Register patrol markers
	patrol_markers.append(drone.repr.worldRepresentation.patrol_marker_1_pos_x)
	patrol_markers.append(drone.repr.worldRepresentation.patrol_marker_2_pos_x)
	
	## Start by going to the furthest marker to the drone
	idx = furthest_marker_idx()
	
	## Assume drone might not be facing in the right direction
	facing_finished = false
	
	## Assume drone might be far enough away for the engines to be on
	engines_stopped = false
	
	arrived = false
	stopped = false
	pause = true
	


func _tick(delta: float) -> Status:
	## Make sure the drone is ready
	if not is_ready():
		prepare()
		return RUNNING
	
	## Make sure the drone is facing the marker it's going to
	if not facing_finished:
		drone.face_toward(patrol_markers[idx], signal_id)
		return RUNNING
	
	var distance_to_marker: float = abs(drone.char_node.global_position.x - patrol_markers[idx])
	
	## Check if drone is far enough to burst
	if distance_to_marker > burst_min_distance:
		if engines_stopped: engines_stopped = false
		if engines_stopping: engines_stopping = false
		drone.burst()
		drone.move_toward_x_pos(patrol_markers[idx], delta)
		return RUNNING
	
	## Check if drone is far enougn to thrust
	if distance_to_marker > thrust_min_distance:
		if engines_stopped: engines_stopped = false
		if engines_stopping: engines_stopping = false
		drone.thrust()
		drone.move_toward_x_pos(patrol_markers[idx], delta)
		return RUNNING
	
	## Check if drone is close enough to stop the engines
	if not engines_stopping:
		drone.stop_engines()
		engines_stopping = true
	
	## If the engines are in the process of stopping, stop moving
	if not engines_stopped:
		drone.stop_moving(delta)
		return RUNNING
	
	## Check if drone has arrived at marker
	if distance_to_marker < arrived_min_distance:
		arrived = true
	
	## If drone hasn't arrived, just keep moving
	if not arrived:
		drone.move_toward_x_pos(patrol_markers[idx], delta)
		return RUNNING
	
	## If drone has arrived but not stopped, just keep on stopping
	if not stopped:
		drone.stop_moving(delta)
		if abs(drone.physics_mode_states.left_right_axis) < 0.001:
			stopped = true
		return RUNNING
	
	## Take a pause after stopping (to maybe stop further?)
	if pause:
		if time_elapsed_paused < pause_when_stopped_duration:
			time_elapsed_paused += delta
			drone.stop_moving(delta)
			return RUNNING
		else:
			pause = false
	
	## If the code made it this far, the drone is ready to go toward the next marker
	facing_finished = false
	arrived = false
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


func prepare() -> void:
	## Sync state changes
	if not drone.physics_mode_states.state == drone.physics_mode_states.State.CHAR:
		drone.become_char()
	if not drone.vulnerability_states.state == drone.vulnerability_states.State.INVULNERABLE:
		drone.become_invulnerable()
	if drone.targeting_states.state == drone.targeting_states.State.DISABLED:
		drone.enable_targeting()
	
	## Async state changes
	if not drone.engagement_mode_states.state == drone.engagement_mode_states.State.CLOSED:
		is_closed = false
		drone.close(signal_id)
	else:
		is_closed = true

	if not drone.engines_states.state == drone.engines_states.State.OFF:
		engines_stopped = false
		drone.stop_engines(signal_id)
	else:
		engines_stopped =true


func is_ready() -> bool:
	if not drone.physics_mode_states.state == drone.physics_mode_states.State.CHAR:
		return false
	if not drone.vulnerability_states.state == drone.vulnerability_states.State.INVULNERABLE:
		return false
	if drone.targeting_states.state == drone.targeting_states.State.DISABLED:
		return false
	if drone.targeting_states.state == drone.targeting_states.State.DISABLED:
		return false
	if not is_closed:
		return false
	if not engines_stopped:
		return false
	return true


##########################################
## SIGNALS                             ##
##########################################
func _on_face_toward_finished(id: int) -> void:
	if signal_id == id:
		facing_finished = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		engines_stopped = true


func _on_close_finished(id: int) -> void:
	if signal_id == id:
		is_closed = true
