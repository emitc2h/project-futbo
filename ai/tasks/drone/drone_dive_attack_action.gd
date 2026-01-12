class_name DroneDiveAttackAction
extends DroneBaseAction

## Parameters
@export var target_velocity: float = 12.0
@export var acceleration: float = 60.0
@export var time_closed: float = 3.0

## Internal References
var open_at_end_id: int
var time_elapsed_closed: float

## Progress gates
var premature_hit: bool
var repr_updates_disabled: bool
var is_accelerating_up: bool
var is_done_accelerating_up: bool
var is_closing: bool
var is_closed: bool
var is_char_and_defendable_again: bool
var is_done_facing_target_at_end: bool
var is_facing_target_at_end: bool
var is_opening_at_end: bool
var is_open_at_end: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	super._setup()
	drone.hit_player_in_char_mode.connect(_on_hit_player_in_char_mode)
	drone.open_finished.connect(_on_open_finished)
	drone.accelerate_finished.connect(_on_accelerate_finished)
	drone.quick_close_finished.connect(_on_quick_close_finished)
	drone.face_toward_finished.connect(_on_face_finished)


func _enter() -> void:
	super._enter()
	open_at_end_id = rng.randi()
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.DEFENDABLE,
		DroneTargetingStates.State.DISABLED,
		DroneProximityStates.State.DISABLED,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_open()
	set_initial_stop_engines()
	set_initial_stop_moving(true, 35.0)
	
	premature_hit = false
	repr_updates_disabled = false
	is_accelerating_up = false
	is_done_accelerating_up = false
	is_closing = false
	is_closed = false
	is_char_and_defendable_again = false
	is_done_facing_target_at_end = false
	is_facing_target_at_end = false
	is_opening_at_end = false
	is_open_at_end = false
	
	time_elapsed_closed = 0.0


func custom_tick(delta: float) -> Status:
	if not repr_updates_disabled:
		drone.repr.disable_updates()
		repr_updates_disabled = true
	
	if premature_hit:
		drone.enable_targeting(true)
		drone.repr.enable_updates()
		drone.enable_proximity_detector()
		return SUCCESS

	if not is_done_accelerating_up:
		if not is_accelerating_up:
			var d: float = drone.targeting_states.target.global_position.x - drone.char_node.global_position.x
			var angle_of_reach: float = PI/4 + 0.5 * acos((12.0 * d)/(target_velocity * target_velocity))
			drone.accelerate(angle_of_reach, acceleration, target_velocity, signal_id)
			is_accelerating_up = true
		return RUNNING
	
	if not is_closed:
		if not is_closing:
			drone.become_invulnerable()
			drone.become_rigid()
			drone.quick_close(signal_id)
			is_closing = true
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
			drone.face_toward(drone.targeting_states.target.global_position.x, signal_id)
			is_facing_target_at_end = true
		return RUNNING
	
	drone.enable_targeting(true)
	
	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_hit_player_in_char_mode() -> void:
	premature_hit = true


func _on_accelerate_finished(id: int) -> void:
	if signal_id == id:
		drone.prepare_dive_impact()
		is_done_accelerating_up = true


func _on_quick_close_finished(id: int) -> void:
	if signal_id == id:
		is_closed = true


func _on_open_finished(id: int) -> void:
	super._on_open_finished(id)
	if open_at_end_id == id:
		is_open_at_end = true


func _on_face_finished(id: int) -> void:
	if signal_id == id:
		is_done_facing_target_at_end = true
