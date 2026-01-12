class_name DroneTrackAction
extends DroneBaseAction

## Parameters
@export_group("Main Parameters")
@export var default_offset: float = 5.0
@export var timeout: float = 4.0

@export_group("Evasive Maneuvers")
@export var evasive_maneuvers: bool = false
@export var jump_strength: float = 42.0
@export var jump_period: float = 0.9

@export_group("Blackboard Variables")
@export var offset: StringName = &"tracking_offset"


## Internal References
var time_elapsed: float
var time_until_next_jump: float

## Initial state flags
var targeting_enabled: bool
var is_open: bool
var engines_are_off: bool
var is_defendable: bool

## Progress gates
var is_accelerating: bool
var is_done_jumping: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	super._setup()
	drone.accelerate_finished.connect(_on_accelerate_finished)


func _enter() -> void:
	super._enter()
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.DEFENDABLE,
		DroneTargetingStates.State.ACQUIRED,
		DroneProximityStates.State.ENABLED,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_stop_engines()
	set_initial_open()
	
	time_elapsed = 0.0


func custom_tick(delta: float) -> Status:
	## Check if the tracking has timed out
	time_elapsed += delta
	if time_elapsed > timeout:
		return SUCCESS
		
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
## SIGNALS                             ##
##########################################
func _on_accelerate_finished(id: int) -> void:
	if signal_id == id:
		is_done_jumping = true
