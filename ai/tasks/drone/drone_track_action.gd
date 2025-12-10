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

var is_opening: bool
var is_open: bool
var engines_stopping: bool
var engines_are_off: bool
var is_defendable: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)


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
	
	if not is_open:
		if not is_opening:
			drone.open(signal_id)
			is_opening = true
		
	if not engines_are_off:
		if not engines_stopping:
			drone.stop_engines(signal_id)
			engines_stopping = true
		engines_are_off = true
	
	if not is_defendable:
		drone.become_defendable()
		is_defendable = true
	
	drone.track_target(default_offset + blackboard.get_var(offset, 0.0), delta, signal_id)
	return RUNNING


##########################################
## UTILITIES                           ##
##########################################
func probe_initial_state() -> void:
	match(drone.engagement_mode_states.state):
		drone.engagement_mode_states.State.OPENING:
			is_opening = true
			is_open = false
		drone.engagement_mode_states.State.OPEN:
			is_opening = false
			is_open = true
		_:
			is_open = false
	
	match(drone.engines_states.state):
		drone.engines_states.State.STOPPING:
			engines_are_off = false
			engines_stopping = true
		drone.engines_states.State.OFF:
			engines_are_off = true
			engines_stopping = false
		_:
			engines_are_off = false
	
	match(drone.vulnerability_states.state):
		drone.vulnerability_states.State.DEFENDABLE:
			is_defendable = true
		_:
			is_defendable = false


##########################################
## SIGNALS                             ##
##########################################
func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_open = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		engines_are_off = true
