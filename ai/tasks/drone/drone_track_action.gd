class_name DroneTrackAction
extends BTAction

## Parameters
@export var default_offset: float = 5.0
@export var timeout: float = 4.0
@export var offset: StringName = &"tracking_offset"

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time_elapsed: float

var is_open: bool
var engines_are_off: bool
var is_defendable: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	time_elapsed = 0.0
	
	probe_initial_state()


func _tick(delta: float) -> Status:
	## Check if the tracking has timed out
	time_elapsed += delta
	if time_elapsed > timeout:
		return SUCCESS
	
	## Launch the command to open the drone async
	if not is_open:
		drone.open()
		
	if not engines_are_off:
		drone.stop_engines()
		engines_are_off = true
	
	if not is_defendable:
		drone.become_defendable()
		is_defendable = true
	
	drone.track_target(default_offset + blackboard.get_var(offset, 0.0), delta)
	return RUNNING


##########################################
## UTILITIES                           ##
##########################################
func probe_initial_state() -> void:
	match(drone.engagement_mode_states.state):
		drone.engagement_mode_states.State.OPENING, drone.engagement_mode_states.State.OPEN:
			is_open = true
		_:
			is_open = false
	
	match(drone.engines_states.state):
		drone.engines_states.State.OFF:
			engines_are_off = true
		_:
			engines_are_off = false
	
	match(drone.vulnerability_states.state):
		drone.vulnerability_states.State.DEFENDABLE:
			is_defendable = true
		_:
			is_defendable = false
