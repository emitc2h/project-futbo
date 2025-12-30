class_name DroneBeamAttackAction
extends BTAction

const TARGET_PLAYER: String = "player"
const TARGET_CONTROL_NODE: String = "control node"

## Parameters
@export_group("Main Parameters")
@export var number_of_hits: int = 1
@export_enum(TARGET_PLAYER, TARGET_CONTROL_NODE) var target: String

@export_group("Tracking Parameters")
@export var offset: StringName = &"tracking_offset"
@export var default_offset: float = 5.0

@export_group("Targeting Parameters")
@export var target_switching_delay: float = 1.2
@export var target_control_node_while_dribbling: bool = false
@export var switch_to_control_node_target_delay: float = 0.5

@export_group("Evasive Maneuvers")
@export var evasive_maneuvers: bool = false
@export var jump_strength: float = 30.0
@export var jump_period: float = 0.8

## Internal References
var drone: Drone
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var initial_target: Node3D
var targeting_delay_time_elapsed: float
var not_dribbling_time_elapsed: float
var time_until_next_jump: float

## Other gates
var has_switched_to_real_target: bool

## Progress gates
var is_open: bool
var is_opening: bool
var is_defendable: bool
var is_vulnerable: bool
var fire_command_sent: bool
var has_fired: bool
var is_accelerating: bool
var is_done_jumping: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	drone = agent as Drone
	drone.open_finished.connect(_on_open_finished)
	drone.fire_finished.connect(_on_fire_finished)
	drone.accelerate_finished.connect(_on_accelerate_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	signal_id = rng.randi()
	
	## Set the target
	initial_target = drone.get_target()
	targeting_delay_time_elapsed = 0.0
	has_switched_to_real_target = false
	not_dribbling_time_elapsed = 0.0
	time_until_next_jump = 0.0
	
	
	probe_initial_state()
	
	## Drone hasn't fired yet
	fire_command_sent = false
	has_fired = false
	is_accelerating = false
	is_done_jumping = false


func _tick(delta: float) -> Status:
	
	## Track the drone's target during the entire attack
	drone.track_target(default_offset + blackboard.get_var(offset, 0.0), delta, signal_id)
	
	#print("target_type: ", drone.targeting_states.TargetType.keys()[drone.targeting_states.target_type])
	#print(drone.targeting_states.target.get_groups())
	
	## Count down to switching to actual target
	if not has_switched_to_real_target:
		targeting_delay_time_elapsed += delta
		if targeting_delay_time_elapsed > target_switching_delay:
			match(target):
				TARGET_PLAYER:
					drone.set_target(Representations.player_target_marker)
				TARGET_CONTROL_NODE:
					drone.set_target(Representations.control_node_target_marker)
			has_switched_to_real_target = true
	
	if not is_open:
		if not is_opening:
			drone.open(signal_id)
			is_opening = true
		return RUNNING
	
	if not is_vulnerable:
		drone.become_vulnerable()
		is_vulnerable = true
	
	if not fire_command_sent:
		drone.fire(number_of_hits, signal_id)
		fire_command_sent = true
		
	if not has_fired:
		## If the player is dribbling, the control node is the target
		## If the player stops dribbling for more than some time, the target
		## switches to the player itself
		if target_control_node_while_dribbling and has_switched_to_real_target:
			if drone.repr.playerRepresentation.is_dribbling:
				not_dribbling_time_elapsed = 0.0
				drone.set_target(Representations.control_node_target_marker)
			else:
				not_dribbling_time_elapsed += delta
			
			if not_dribbling_time_elapsed > switch_to_control_node_target_delay:
				drone.set_target(Representations.player_target_marker)
		
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
		
		return RUNNING

	drone.become_defendable()
	return SUCCESS


func _exit() -> void:
	drone.set_target(initial_target)


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
		time_until_next_jump = 0.0
		has_fired = true


func _on_accelerate_finished(id: int) -> void:
	if signal_id == id:
		is_done_jumping = true
