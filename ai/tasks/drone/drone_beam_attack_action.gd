class_name DroneBeamAttackAction
extends DroneBaseAction

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
@export var switch_back_to_player_delay: float = 0.5

@export_group("Evasive Maneuvers")
@export var evasive_maneuvers: bool = false
@export var jump_strength: float = 42.0
@export var jump_period: float = 0.9

## Internal References
var targeting_delay_time_elapsed: float
var not_dribbling_time_elapsed: float
var time_until_next_jump: float

## Other gates
var has_switched_to_real_target: bool
var target_switched_to_control_node: bool

## Progress gates
var is_vulnerable: bool
var repr_updates_disabled: bool
var fire_command_sent: bool
var has_fired: bool
var is_accelerating: bool
var is_done_jumping: bool


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	super._setup()
	drone.fire_finished.connect(_on_fire_finished)
	drone.accelerate_finished.connect(_on_accelerate_finished)


func _enter() -> void:
	super._enter()
	
	set_initial_states(
		DronePhysicsModeStates.State.CHAR,
		DroneVulnerabilityStates.State.DEFENDABLE,
		DroneTargetingStates.State.ACQUIRED,
		DroneProximityStates.State.DISABLED,
		DroneTargetingStates.TargetType.PLAYER,
		true)
	
	set_initial_open()
	set_initial_stop_engines()
	set_initial_stop_moving()
	
	## Set the target
	targeting_delay_time_elapsed = 0.0
	has_switched_to_real_target = false
	not_dribbling_time_elapsed = 0.0
	time_until_next_jump = 0.0
	
	## Drone hasn't fired yet
	target_switched_to_control_node = false
	repr_updates_disabled = false
	is_vulnerable = false
	fire_command_sent = false
	has_fired = false
	is_accelerating = false
	is_done_jumping = false


func custom_tick(delta: float) -> Status:
	## Track the drone's target during the entire attack
	drone.track_target(default_offset + blackboard.get_var(offset, 0.0), delta, signal_id)
	
	## Count down to switching to actual target
	if not has_switched_to_real_target:
		targeting_delay_time_elapsed += delta
		if targeting_delay_time_elapsed > target_switching_delay:
			match(target):
				TARGET_PLAYER:
					drone.set_target(Representations.player_target_marker, true)
				TARGET_CONTROL_NODE:
					drone.set_target(Representations.control_node_target_marker, true)
			has_switched_to_real_target = true
	
	if not is_vulnerable:
		drone.become_vulnerable()
		is_vulnerable = true

	if not repr_updates_disabled:
		drone.repr.disable_updates()
		repr_updates_disabled = true

	if not fire_command_sent:
		drone.fire(number_of_hits, signal_id)
		fire_command_sent = true
		
	if not has_fired:
		## If the player is dribbling, the control node is the target
		## If the player stops dribbling for more than some time, the target
		## switches to the player itself
		if target_control_node_while_dribbling and has_switched_to_real_target:
			## Read from the global representation cause the local one isn't updating
			if Representations.player_representation.is_dribbling:
				if not target_switched_to_control_node:
					not_dribbling_time_elapsed = 0.0
					drone.set_target(Representations.control_node_target_marker, true)
					target_switched_to_control_node = true
			else:
				not_dribbling_time_elapsed += delta
			
			if not_dribbling_time_elapsed > switch_back_to_player_delay:
				if target_switched_to_control_node:
					drone.set_target(Representations.player_target_marker)
					target_switched_to_control_node = false
		
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
	
	drone.repr.enable_updates()
	drone.become_defendable()
	drone.set_target(Representations.player_target_marker)

	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_fire_finished(id: int) -> void:
	if signal_id == id:
		time_until_next_jump = 0.0
		has_fired = true


func _on_accelerate_finished(id: int) -> void:
	if signal_id == id:
		is_done_jumping = true
