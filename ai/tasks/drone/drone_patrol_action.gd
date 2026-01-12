class_name DronePatrolAction
extends DroneBaseAction

## Parameters
@export var arrived_min_distance: float = 1.0
@export var pause_when_stopped_duration: float = 0.5

## Internal References
var patrol_markers: Array[float]
var idx: int = 0
var time_elapsed_paused: float = 0.0

## Progress gates
var is_invulnerable: bool
var is_turning: bool
var is_facing_next_marker: bool
var stopped: bool
var pause: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	super._setup()
	
	## Connect facing signals
	drone.face_toward_finished.connect(_on_face_toward_finished)


func _enter() -> void:
	super._enter()
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.DEFENDABLE,
		DroneTargetingStates.State.NONE,
		DroneProximityStates.State.ENABLED,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_stop_engines()
	set_initial_close(true)
	
	## Register patrol markers
	patrol_markers.append(drone.repr.worldRepresentation.patrol_marker_1_pos)
	patrol_markers.append(drone.repr.worldRepresentation.patrol_marker_2_pos)
	
	## Start by going to the furthest marker to the drone
	idx = furthest_marker_idx()
	
	## Dynamic progress gates
	is_invulnerable = false
	is_turning = false
	is_facing_next_marker = false
	stopped = false
	pause = true


func custom_tick(delta: float) -> Status:
	## Once the drone is closed, it should become invulnerable
	if not is_invulnerable:
		drone.become_invulnerable()
		is_invulnerable = true
	
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
		if abs(drone.char_node.velocity.length()) < 0.05:
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


##########################################
## SIGNALS                             ##
##########################################
func _on_face_toward_finished(id: int) -> void:
	if signal_id == id:
		is_facing_next_marker = true
