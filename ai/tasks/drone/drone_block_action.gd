class_name DroneBlockAction
extends DroneBaseAction

## Parameters
@export var control_node_exited_buffer: float = 0.5
@export var use_proximity_zone: bool = true
@export var stay_closed_for_max_time: float = 2.0

## Internal References
var time_elapsed_in_buffer: float
var time_closed: float

## Progress gates
var is_closing: bool
var is_closed: bool
var repr_updates_disabled: bool
var is_counting_down_to_open: bool
var stopped: bool
var control_node_has_exited: bool
var in_buffer: bool
var is_opening: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	super._setup()
	drone.quick_close_finished.connect(_on_quick_close_finished)
	drone.proximity_states.control_node_proximity_exited.connect(_on_control_node_proximity_exited)
	drone.proximity_states.control_node_proximity_entered.connect(_on_control_node_proximity_entered)


func _enter() -> void:
	super._enter()
	
	time_elapsed_in_buffer = 0.0
	time_closed = 0.0
	
	var proximity_detector_initial_state: DroneProximityStates.State
	if use_proximity_zone:
		proximity_detector_initial_state = DroneProximityStates.State.ENABLED
		control_node_has_exited = false
	else:
		proximity_detector_initial_state = DroneProximityStates.State.DISABLED
		control_node_has_exited = true
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.INVULNERABLE,
		DroneTargetingStates.State.ACQUIRING,
		proximity_detector_initial_state,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_stop_moving(false, 30.0)
	
	is_closed = drone.engagement_mode_states.state == drone.engagement_mode_states.State.CLOSED
	is_closing = false
	in_buffer = true
	repr_updates_disabled = false
	is_counting_down_to_open = false


func custom_tick(delta: float) -> Status:
	## Order the drone to quick close if not already closed or closing
	if not is_closed:
		if not is_closing:
			drone.quick_close(signal_id)
			is_closing = true
		return RUNNING
	
	if not repr_updates_disabled:
		drone.repr.disable_updates()
		repr_updates_disabled = true
	
	if not is_counting_down_to_open:
		time_closed = 0.0
		is_counting_down_to_open = true
	
	time_closed += delta
	
	## If the max time closed is elapsed, bypass the rest of the requirements
	## This helps when the drone "swallows" the control node
	if time_closed > stay_closed_for_max_time:
		control_node_has_exited = true
		in_buffer = false
	
	## Wait for the control node to exit the proximity zone
	if not control_node_has_exited:
		return RUNNING
	
	if in_buffer:
		time_elapsed_in_buffer += delta
		if time_elapsed_in_buffer < control_node_exited_buffer:
			return RUNNING
		in_buffer = false
	
	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_quick_close_finished(id: int) -> void:
	if id == signal_id:
		is_closed = true


func _on_control_node_proximity_exited() -> void:
	control_node_has_exited = true


func _on_control_node_proximity_entered() -> void:
	time_elapsed_in_buffer = 0.0
