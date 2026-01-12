class_name DroneBaseAction
extends BTAction

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Progress gates for potentially blocking state changes
var _initial_opened: bool = true
var _initial_open_blocking: bool = false
var _is_initial_opening: bool = false

var _initial_closed: bool = true
var _initial_close_blocking: bool = false
var _is_initial_closing: bool = false

var _initial_engines_stopped: bool = true
var _initial_stop_engines_blocking: bool = false
var _is_initial_engines_stopping: bool = false

var _initial_stopped_moving: bool = true
var _initial_stop_moving_blocking: bool = false
var _initial_stop_moving_lerp_factor: float = 10.0


func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.close_finished.connect(_on_closed_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()


func _tick(delta: float) -> Status:
	## Handle initial open
	if not _initial_opened:
		if not _is_initial_opening:
			drone.open(signal_id)
			_is_initial_opening = true
		if _initial_open_blocking:
			return RUNNING
		else:
			_initial_opened = true
	
	## Handle initial close
	if not _initial_closed:
		if not _is_initial_closing:
			drone.close(signal_id)
			_is_initial_closing = true
		if _initial_close_blocking:
			return RUNNING
		else:
			_initial_closed = true
	
	## Handle initial engines stop
	if not _initial_engines_stopped:
		if not _is_initial_engines_stopping:
			drone.stop_engines(signal_id)
			_is_initial_engines_stopping = true
		if _initial_stop_engines_blocking:
			return RUNNING
		else:
			_initial_engines_stopped = true
	
	## Handle initial stop moving
	if not _initial_stopped_moving:
		if not drone.char_node.velocity.x < 0.005:
			drone.stop_moving(delta, _initial_stop_moving_lerp_factor)
			if _initial_stop_engines_blocking:
				return RUNNING
		else:
			_initial_stopped_moving = true
	
	## The rest of the action is implemented in the derived action by overriding custom_tick
	return custom_tick(delta)


##########################################
## CONTROLS                            ##
##########################################
@warning_ignore("unused_parameter")
func custom_tick(delta: float) -> Status:
	## Override this method for custom functionality
	return SUCCESS


func set_initial_states(
	initial_physics: DronePhysicsModeStates.State,
	initial_vulnerability: DroneVulnerabilityStates.State,
	initial_targeting: DroneTargetingStates.State,
	initial_proximity: DroneProximityStates.State,
	initial_target_type: DroneTargetingStates.TargetType,
	initial_repr_updates_enabled: bool
	) -> void:
	if not initial_physics == drone.physics_mode_states.state:
		match(initial_physics):
			DronePhysicsModeStates.State.CHAR:
				drone.become_char()
			DronePhysicsModeStates.State.RIGID:
				drone.become_rigid()
			DronePhysicsModeStates.State.RAGDOLL:
				drone.become_ragdoll()
			## Drone shouldn't accept any behavior while in DEAD state
		
	if not initial_vulnerability == drone.vulnerability_states.state:
		match(initial_vulnerability):
			DroneVulnerabilityStates.State.INVULNERABLE:
				drone.become_invulnerable()
			DroneVulnerabilityStates.State.DEFENDABLE:
				drone.become_defendable()
			DroneVulnerabilityStates.State.VULNERABLE:
				drone.become_vulnerable()
	
	## Engagement states here is ignored because it can be blocking or async state change
	
	## Same goes for Engine states
	
	if not initial_targeting == drone.targeting_states.state:
		match(initial_targeting):
			DroneTargetingStates.State.NONE:
				drone.enable_targeting()
			DroneTargetingStates.State.ACQUIRING:
				drone.enable_targeting(true)
			DroneTargetingStates.State.ACQUIRED:
				drone.enable_targeting(true)
			DroneTargetingStates.State.DISABLED:
				drone.disable_targeting()
	
	if not initial_proximity == drone.proximity_states.state:
		match(initial_proximity):
			DroneProximityStates.State.ENABLED:
				drone.enable_proximity_detector()
			DroneProximityStates.State.DISABLED:
				drone.disable_proximity_detector()
	
	if not initial_target_type == drone.targeting_states.target_type:
		match(initial_target_type):
			DroneTargetingStates.TargetType.PLAYER:
				drone.set_target(Representations.player_target_marker)
			DroneTargetingStates.TargetType.CONTROL_NODE:
				drone.set_target(Representations.control_node_target_marker)
	
	if initial_repr_updates_enabled:
		drone.repr.enable_updates()
	else:
		drone.repr.disable_updates()


func set_initial_open(blocking: bool = false) -> void:
	_initial_opened = drone.engagement_mode_states.state == DroneEngagementModeStates.State.OPEN
	_is_initial_opening = false
	_initial_open_blocking = blocking


func set_initial_close(blocking: bool = false) -> void:
	_initial_closed = drone.engagement_mode_states.state == DroneEngagementModeStates.State.CLOSED
	_is_initial_closing = false
	_initial_close_blocking = blocking


func set_initial_stop_engines(blocking: bool = false) -> void:
	_initial_engines_stopped = drone.engines_states.state == DroneEnginesStates.State.OFF
	_is_initial_engines_stopping = false
	_initial_stop_engines_blocking = blocking


func set_initial_stop_moving(blocking: bool = false, lerp_factor: float = 10.0) -> void:
	_initial_stopped_moving = drone.char_node.velocity.x < 0.005
	_initial_stop_moving_blocking = blocking
	_initial_stop_moving_lerp_factor = lerp_factor


##########################################
## SIGNALS                              ##
##########################################
func _on_open_finished(id: int) -> void:
	if signal_id == id:
		_initial_opened = true


func _on_closed_finished(id: int) -> void:
	if signal_id == id:
		_initial_closed = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		_initial_engines_stopped = true
