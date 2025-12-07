class_name DroneBeamAttackAction
extends BTAction

## Parameters
@export var number_of_hits: int = 1

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Progress gates
var is_open: bool
var is_opening: bool
var is_defendable: bool
var is_vulnerable: bool
var fire_command_sent: bool
var has_fired: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.fire_finished.connect(_on_fire_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	probe_initial_state()
	
	## Drone hasn't fired yet
	fire_command_sent = false
	has_fired = false


func _tick(delta: float) -> Status:
	if not is_open:
		if not is_opening:
			drone.open(signal_id)
			is_opening = true
		return RUNNING
	
	if not (abs(drone.physics_mode_states.left_right_axis) < 0.001):
		drone.stop_moving(delta, 1.0)
	
	if not is_vulnerable:
		drone.become_vulnerable()
		is_vulnerable = true
	
	if not fire_command_sent:
		drone.fire(number_of_hits, signal_id)
		fire_command_sent = true
		
	if not has_fired:
		return RUNNING
	
	drone.become_defendable()
	return SUCCESS


##########################################
## UTILITIES                           ##
##########################################
func probe_initial_state() -> void:
	match(drone.engagement_mode_states.state):
		drone.engagement_mode_states.State.OPEN:
			is_open = true
			is_opening = false
		drone.engagement_mode_states.State.OPENING:
			is_open = false
			is_opening = true
		_:
			is_open = false
			is_opening = false
	
	match(drone.vulnerability_states.state):
		drone.vulnerability_states.State.DEFENDABLE:
			is_defendable = true
		_:
			is_defendable = false
	
	## just assume the drone isn't vulnerable until it is open
	is_vulnerable = false


##########################################
## SIGNALS                             ##
##########################################
func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_open = true


func _on_fire_finished(id: int) -> void:
	if signal_id == id:
		has_fired = true
