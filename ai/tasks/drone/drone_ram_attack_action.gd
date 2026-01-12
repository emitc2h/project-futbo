class_name DroneRamAttackAction
extends DroneBaseAction

## Parameters
@export var distance_to_turn_around: float = 11.0
@export var distance_to_turn_into_ball: float = 7.0
@export var time_closed: float = 1.5

## Internal References
var face_away_id: int
var face_toward_id: int
var open_at_end_id: int
var facing_target_at_end_id: int
var time_elapsed_closed: float

## Progress gates
var premature_hit: bool
var premature_stopped: bool
var premature_stopping: bool
var is_facing_away: bool
var is_done_facing_away: bool
var is_bursting_away: bool
var is_done_bursting_away: bool
var is_stopping_engines: bool
var has_stopped: bool
var has_turned_back_toward_player: bool
var proximity_detector_disabled: bool
var repr_updates_disabled: bool
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
	super._setup()
	drone.hit_player_in_char_mode.connect(_on_hit_player_in_char_mode)
	drone.open_finished.connect(_on_open_finished)
	drone.face_toward_finished.connect(_on_face_finished)
	drone.face_away_finished.connect(_on_face_finished)
	drone.quick_close_finished.connect(_on_quick_close_finished)


func _enter() -> void:
	super._enter()
	
	face_away_id = rng.randi()
	face_toward_id = rng.randi()
	open_at_end_id = rng.randi()
	facing_target_at_end_id = rng.randi()
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.DEFENDABLE,
		DroneTargetingStates.State.DISABLED,
		DroneProximityStates.State.DISABLED,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_open()
	set_initial_stop_engines(true)
	set_initial_stop_moving(true, 35.0)
	
	premature_hit = false
	premature_stopped = false
	premature_stopping = false
	is_done_facing_away = false
	is_facing_away = false
	is_done_bursting_away = false
	is_bursting_away = false
	has_stopped = false
	is_stopping_engines = false
	has_turned_back_toward_player = false
	repr_updates_disabled = false
	is_done_bursting_back = false
	is_bursting_back = false
	is_closed = false
	is_char_and_defendable_again = false
	is_opening_at_end = false
	is_open_at_end = false
	is_facing_target_at_end = false
	is_done_facing_target_at_end = false
	
	time_elapsed_closed = 0.0


func custom_tick(delta: float) -> Status:
	if not is_done_facing_away:
		if not is_facing_away:
			drone.face_away(drone.targeting_states.target.global_position.x, face_away_id)
			is_facing_away = true
		return RUNNING
	
	if premature_hit:
		print("Premature HIT")
		drone.repr.enable_updates()
		drone.enable_proximity_detector()
		drone.enable_targeting(true)
		if not premature_stopped:
			if not premature_stopping:
				drone.quick_stop_engines()
				premature_stopping = true
			drone.stop_moving(delta, 50.0)
			if abs(drone.physics_mode_states.left_right_axis) < 0.001:
				premature_stopped = true
			else:
				return RUNNING
		return SUCCESS
		
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
		drone.stop_moving(delta, 100.0)
		if not is_stopping_engines:
			drone.stop_engines()
			is_stopping_engines = true
		if abs(drone.physics_mode_states.left_right_axis) < 0.001:
			has_stopped = true
		return RUNNING
	
	if not has_turned_back_toward_player:
		drone.face_toward(drone.repr.playerRepresentation.global_position.x, face_toward_id)
		return RUNNING
	
	if not proximity_detector_disabled:
		drone.disable_proximity_detector()
		proximity_detector_disabled = true
	
	if not repr_updates_disabled:
		drone.repr.disable_updates()
		repr_updates_disabled = true
	
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
		drone.repr.enable_updates()
		drone.become_char()
		drone.become_defendable()
		drone.enable_proximity_detector()
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
	
	drone.enable_targeting(true)
	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_hit_player_in_char_mode() -> void:
	premature_hit = true


func _on_open_finished(id: int) -> void:
	super._on_open_finished(id)
	if open_at_end_id == id:
		is_open_at_end = true


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
