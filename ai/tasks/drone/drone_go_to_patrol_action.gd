class_name DroneGoToPatrolAction
extends BTAction

## Parameters
@export var arrived_min_distance: float = 0.1
@export var burst_min_distance: float = 35.0
@export var thrust_min_distance: float = 10.0

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var destination: float

## Progress gates
var ready: bool
var facing_finished: bool
var engines_stopping: bool
var engines_stopped: bool
var bursting: bool
var thrusting: bool
var is_open: bool
var arrived: bool
var stopped: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	
	## Connect facing signals
	drone.face_toward_finished.connect(_on_face_toward_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)
	drone.open_finished.connect(_on_open_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	## Prepare the drone state
	prepare()
	
	## Destination is between the patrol markers
	destination = (drone.repr.worldRepresentation.patrol_marker_1_pos_x + drone.repr.worldRepresentation.patrol_marker_2_pos_x) / 2.0
	
	## Assume drone might not be facing in the right direction
	facing_finished = false
	
	## Assume drone might be far enough away for the engines to be on
	engines_stopped = false
	
	ready = false
	bursting = false
	thrusting = false
	arrived = false
	stopped = false


func _tick(delta: float) -> Status:
	## Make sure the drone is ready
	if not ready:
		drone.stop_moving(delta)
		prepare()
		if is_ready():
			ready = true
		else:
			return RUNNING
	
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
		drone.stop_engines(signal_id)
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
		if abs(drone.physics_mode_states.left_right_axis) < 0.001:
			stopped = true
		return RUNNING
	
	return SUCCESS

##########################################
## UTILITIES                           ##
##########################################
func prepare() -> void:
	## Sync state changes
	if not drone.physics_mode_states.state == drone.physics_mode_states.State.CHAR:
		drone.become_char()
	if not drone.vulnerability_states.state == drone.vulnerability_states.State.DEFENDABLE:
		drone.become_defendable()
	if drone.targeting_states.state == drone.targeting_states.State.DISABLED:
		drone.enable_targeting()
	
	## Async state changes
	if not drone.engagement_mode_states.state == drone.engagement_mode_states.State.OPEN:
		is_open = false
		drone.open(signal_id)
	else:
		is_open = true

	if not drone.engines_states.state == drone.engines_states.State.OFF:
		engines_stopped = false
		drone.stop_engines(signal_id)
	else:
		engines_stopped = true


func is_ready() -> bool:
	if not drone.physics_mode_states.state == drone.physics_mode_states.State.CHAR:
		return false
	if not drone.vulnerability_states.state == drone.vulnerability_states.State.DEFENDABLE:
		return false
	if drone.targeting_states.state == drone.targeting_states.State.DISABLED:
		return false
	if not is_open:
		return false
	if not engines_stopped:
		return false
	return true


##########################################
## SIGNALS                             ##
##########################################
func _on_face_toward_finished(id: int) -> void:
	if signal_id == id:
		facing_finished = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		engines_stopped = true


func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_open = true
