class_name DroneRamAttackAction
extends BTAction

## Parameters
@export var distance_to_turn_around: float = 11.0
@export var distance_to_turn_into_ball: float = 7.0
@export var time_closed: float = 1.5

## Internal References
var drone: Drone
var signal_id: int
var face_away_id: int
var face_toward_id: int
var open_at_end_id: int
var facing_target_at_end_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time_elapsed_closed: float


## Progress gates
var is_opening: bool
var is_open: bool
var engines_stopping: bool
var engines_are_off: bool
var is_defendable: bool
var targeting_disabled: bool
var is_facing_away: bool
var is_done_facing_away: bool
var is_bursting_away: bool
var is_done_bursting_away: bool
var has_stopped: bool
var has_turned_back_toward_player: bool
var proximity_detector_disabled: bool
var is_bursting_back: bool
var is_done_bursting_back: bool
var is_closed: bool
var is_char_and_defendable_again: bool
var is_opening_at_end: bool
var is_open_at_end: bool
var is_facing_target_at_end: bool
var is_done_facing_target_at_end: bool

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.stop_engines_finished.connect(_on_stop_engines_finished)
	drone.face_toward_finished.connect(_on_face_finished)
	drone.face_away_finished.connect(_on_face_finished)
	drone.quick_close_finished.connect(_on_quick_close_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	face_away_id = rng.randi()
	face_toward_id = rng.randi()
	open_at_end_id = rng.randi()
	facing_target_at_end_id = rng.randi()
	
	probe_initial_state()
	
	is_done_facing_away = false
	is_facing_away = false
	is_done_bursting_away = false
	is_bursting_away = false
	has_stopped = false
	has_turned_back_toward_player = false
	is_done_bursting_back = false
	is_bursting_back = false
	is_closed = false
	is_char_and_defendable_again = false
	is_opening_at_end = false
	is_open_at_end = false
	is_facing_target_at_end = false
	is_done_facing_target_at_end = false
	
	time_elapsed_closed = 0.0


func _tick(delta: float) -> Status:
	if not is_defendable:
		drone.become_defendable()
		is_defendable = true
	
	if not is_open:
		if not is_opening:
			drone.open(signal_id)
			is_opening = true
	
	if not engines_are_off:
		if not engines_stopping:
			drone.stop_engines(signal_id)
			engines_stopping = true
	
	if not targeting_disabled:
		drone.disable_targeting()
		targeting_disabled = true
	
	if not is_done_facing_away:
		if not is_facing_away:
			drone.face_away(drone.targeting_states.target.global_position.x, face_away_id)
			is_facing_away = true
		drone.stop_moving(delta)
		return RUNNING
		
	var distance_to_player: float = abs(drone.repr.playerRepresentation.global_position.x - drone.char_node.global_position.x)
	
	if not is_done_bursting_away:
		if not is_bursting_away:
			drone.burst()
			is_bursting_away = true
		drone.move_toward_x_pos(drone.repr.playerRepresentation.global_position.x, delta, true)
		if distance_to_player > distance_to_turn_around:
			is_done_bursting_away = true
		return RUNNING
	
	if not has_stopped:
		drone.stop_moving(delta)
		drone.stop_engines()
		if abs(drone.physics_mode_states.left_right_axis) < 0.01:
			has_stopped = true
		return RUNNING
	
	if not has_turned_back_toward_player:
		drone.face_toward(drone.repr.playerRepresentation.global_position.x, face_toward_id)
		return RUNNING
	
	if not proximity_detector_disabled:
		drone.disable_proximity_detector()
		proximity_detector_disabled = true
	
	if not is_done_bursting_back:
		if not is_bursting_back:
			drone.burst()
			is_bursting_back = true
		drone.move_toward_x_pos(drone.repr.playerRepresentation.global_position.x, delta)
		if distance_to_player < distance_to_turn_into_ball:
			drone.become_rigid()
			drone.quick_close(signal_id)
			drone.quick_stop_engines(true)
			drone.become_invulnerable()
			is_done_bursting_back = true
		return RUNNING
	
	if not is_closed:
		return RUNNING
	
	if not time_elapsed_closed > time_closed:
		time_elapsed_closed += delta
		return RUNNING
	
	if not is_char_and_defendable_again:
		drone.become_char()
		drone.become_defendable()
		is_char_and_defendable_again = true
	
	if not is_open_at_end:
		if not is_opening_at_end:
			drone.open(open_at_end_id)
			is_opening_at_end = true
		return RUNNING
	
	if not is_done_facing_target_at_end:
		if not is_facing_target_at_end:
			drone.face_toward(drone.targeting_states.target.global_position.x, facing_target_at_end_id)
			is_facing_target_at_end = true
		return RUNNING
	
	drone.enable_targeting()
	drone.enable_proximity_detector()
	
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
	
	match(drone.engines_states.state):
		drone.engines_states.State.OFF:
			engines_are_off = true
			engines_stopping = false
		drone.engines_states.State.STOPPING:
			engines_are_off = false
			engines_stopping = true
		_:
			engines_are_off = false
			engines_stopping = false
	
	match(drone.proximity_states.state):
		drone.proximity_states.State.DISABLED:
			proximity_detector_disabled = true
		_:
			proximity_detector_disabled = false


##########################################
## SIGNALS                             ##
##########################################
func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_open = true
	if open_at_end_id == id:
		is_open_at_end = true


func _on_stop_engines_finished(id: int) -> void:
	if signal_id == id:
		engines_are_off = true


func _on_face_finished(id: int) -> void:
	if face_away_id == id:
		is_done_facing_away = true
	if face_toward_id == id:
		has_turned_back_toward_player = true
	if facing_target_at_end_id == id:
		is_done_facing_target_at_end = true


func _on_quick_close_finished(id: int) -> void:
	if signal_id == id:
		is_closed = true
