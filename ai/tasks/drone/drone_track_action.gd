class_name DroneTrackAction
extends BTAction

## Parameters
@export_group("Main Parameters")
@export var default_offset: float = 5.0
@export var timeout: float = 4.0

@export_group("Evasive Maneuvers")
@export var evasive_maneuvers: bool = false
@export var jump_strength: float = 30.0
@export var jump_period: float = 0.8

@export_group("Blackboard Variables")
@export var offset: StringName = &"tracking_offset"


## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time_elapsed: float
var time_until_next_jump: float

## Progress gates
var targeting_enabled: bool
var is_opening: bool
var is_open: bool
var engines_stopping: bool
var engines_are_off: bool
var is_defendable: bool
var is_accelerating: bool
var is_done_jumping: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)
	drone.accelerate_finished.connect(_on_accelerate_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	## The drone should target the player
	drone.set_target(Representations.player_target_marker)
	
	time_elapsed = 0.0
	
	probe_initial_state()


func _tick(delta: float) -> Status:
	## Check if the tracking has timed out
	time_elapsed += delta
	if time_elapsed > timeout:
		return SUCCESS
		
	if not targeting_enabled:
		drone.enable_targeting()
	
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
		
	## Optional evasive maneuvers: the drone will jump up periodically
	if evasive_maneuvers:
		if not is_done_jumping:
			if not is_accelerating:
				drone.accelerate(PI/2, jump_strength, 1.0 + jump_strength / 10.0, signal_id)
				time_until_next_jump = 0.0
				is_accelerating = true
		else:
			time_until_next_jump += delta
			if time_until_next_jump > jump_period:
				is_done_jumping = false
				is_accelerating = false
	
	drone.track_target(default_offset + blackboard.get_var(offset, 0.0), delta, signal_id)
	return RUNNING


##########################################
## UTILITIES                           ##
##########################################
func probe_initial_state() -> void:
	match(drone.targeting_states.state):
		drone.targeting_states.State.DISABLED:
			targeting_enabled = false
		_:
			targeting_enabled = true
	
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


func _on_accelerate_finished(id: int) -> void:
	if signal_id == id:
		is_done_jumping = true
