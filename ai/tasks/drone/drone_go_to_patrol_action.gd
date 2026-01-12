class_name DroneGoToPatrolAction
extends DroneBaseAction

## Parameters
@export var arrived_min_distance: float = 0.1
@export var burst_min_distance: float = 35.0
@export var thrust_min_distance: float = 10.0

## Internal References
var destination: float

var stop_engines_signal_id: int

## Progress gates
var facing_finished: bool
var engines_stopping: bool
var engines_stopped: bool
var bursting: bool
var thrusting: bool
var arrived: bool
var stopped: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	super._setup()
	
	## Connect signals
	drone.face_toward_finished.connect(_on_face_toward_finished)
	drone.open_finished.connect(_on_open_finished)


func _enter() -> void:
	super._enter()
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.DEFENDABLE,
		DroneTargetingStates.State.NONE,
		DroneProximityStates.State.ENABLED,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_open(true)
	set_initial_stop_moving(true)
	
	## Destination is between the patrol markers
	destination = (drone.repr.worldRepresentation.patrol_marker_1_pos + drone.repr.worldRepresentation.patrol_marker_2_pos) / 2.0
	
	## Assume drone might not be facing in the right direction
	facing_finished = false
	
	## Assume drone might be far enough away for the engines to be on
	engines_stopped = false
	
	bursting = false
	thrusting = false
	stop_engines_signal_id = rng.randi()
	arrived = false
	stopped = false
	
	drone.repr.enable_updates()


func custom_tick(delta: float) -> Status:
	## Make sure the drone is facing the marker it's going to
	if not facing_finished:
		drone.face_toward(destination, signal_id)
		return RUNNING
	
	var distance_to_destination: float = abs(drone.char_node.global_position.x - destination)
	
	## Check if drone is far enough to burst
	if distance_to_destination > burst_min_distance:
		if not bursting:
			drone.burst()
			if engines_stopped: engines_stopped = false
			if engines_stopping: engines_stopping = false
			bursting = true
		
		drone.move_toward_x_pos(destination, delta)
		return RUNNING
	bursting = false
	
	## Check if drone is far enougn to thrust
	if distance_to_destination > thrust_min_distance:
		if not thrusting:
			drone.thrust()
			if engines_stopped: engines_stopped = false
			if engines_stopping: engines_stopping = false
			thrusting = true
		
		drone.move_toward_x_pos(destination, delta)
		return RUNNING
	thrusting = false
	
	## Check if drone is close enough to stop the engines
	if not engines_stopping:
		drone.stop_engines(stop_engines_signal_id)
		engines_stopping = true
	
	## If the engines are in the process of stopping, stop moving
	if not engines_stopped:
		drone.stop_moving(delta)
		return RUNNING
	
	## Check if drone has arrived at marker
	if distance_to_destination < arrived_min_distance:
		arrived = true
	
	## If drone hasn't arrived, just keep moving
	if not arrived:
		drone.move_toward_x_pos(destination, delta)
		return RUNNING
	
	## If drone has arrived but not stopped, just keep on stopping
	if not stopped:
		drone.stop_moving(delta)
		if abs(drone.physics_mode_states.left_right_axis) < 0.005:
			stopped = true
		return RUNNING
	
	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_face_toward_finished(id: int) -> void:
	if signal_id == id:
		facing_finished = true


func _on_stop_engines_finished(id: int) -> void:
	super._on_stop_engines_finished(id)
	if stop_engines_signal_id == id:
		engines_stopped = true
		
