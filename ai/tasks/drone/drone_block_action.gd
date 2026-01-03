class_name DroneBlockAction
extends BTAction

## Parameters
@export var control_node_exited_buffer: float = 0.5

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time_elapsed_in_buffer: float

## Progress gates
var is_vulnerable: bool
var is_closing: bool
var is_closed: bool
var is_invulnerable: bool
var engines_are_off: bool
var stopped: bool
var control_node_has_exited: bool
var in_buffer: bool
var is_opening: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.quick_close_finished.connect(_on_quick_close_finished)
	drone.proximity_states.control_node_proximity_exited.connect(_on_control_node_proximity_exited)
	drone.proximity_states.control_node_proximity_entered.connect(_on_control_node_proximity_entered)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	time_elapsed_in_buffer = 0.0
	
	## Set some of the progress gates according to the state of the drone
	probe_initial_state()
	
	in_buffer = true


func _tick(delta: float) -> Status:
	## If the drone is VULNERABLE, you can't block so fail the BLOCK
	if is_vulnerable:
		return SUCCESS
	
	## Stop the drone in its tracks
	if not engines_are_off:
		drone.reset_engines()
		engines_are_off = true
	
	if not stopped:
		if abs(drone.physics_mode_states.left_right_axis) < 0.01:
			stopped = true
		else:
			drone.stop_moving(delta, 30.0)
	
	## Order the drone to quick close if not already closed or closing
	if not is_closing:
		if not is_closed:
			drone.quick_close(signal_id)
		is_closing = true
	
	## Become invulnerable immediately so the shield reacts
	if not is_invulnerable:
		drone.become_invulnerable()
		is_invulnerable = true
	
	## Wait for the drone to finish closing
	if not is_closed:
		return RUNNING
	
	## Wait for the control node to exit the proximity zone
	if not control_node_has_exited:
		time_elapsed_in_buffer = 0.0
		return RUNNING
	
	if in_buffer:
		time_elapsed_in_buffer += delta
		if time_elapsed_in_buffer < control_node_exited_buffer:
			return RUNNING
		in_buffer = false
	
	## Once the cycle is all done, open the drone and make it defendable again
	drone.open()
	drone.become_defendable()
	return SUCCESS


##########################################
## UTILITIES                           ##
##########################################
func probe_initial_state() -> void:
	match(drone.engagement_mode_states.state):
		drone.engagement_mode_states.State.CLOSED:
			is_closed = true
			is_closing = false
		drone.engagement_mode_states.State.QUICK_CLOSE:
			is_closed = false
			is_closing = true
		_:
			is_closed = false
			is_closing = false
	
	match(drone.vulnerability_states.state):
		drone.vulnerability_states.State.INVULNERABLE:
			is_invulnerable = true
			is_vulnerable = false
		drone.vulnerability_states.State.VULNERABLE:
			is_vulnerable = true
		_:
			is_invulnerable = false
			is_vulnerable = false
	
	match(drone.engines_states.state):
		drone.engines_states.State.OFF, drone.engines_states.State.STOPPING:
			engines_are_off = true
		_:
			engines_are_off = false
	
	if abs(drone.physics_mode_states.left_right_axis) < 0.01:
		stopped = true
	
	## Assume this to be false since the control node entering the proximity zone is what
	## triggers the BLOCK action to being with
	control_node_has_exited = false


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
