class_name DroneAttackStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var behavior_states: DroneBehaviorStates
@export var targeting_states: DroneTargetingStates
@export var internal_representation: DroneInternalRepresentation

@export_group("Parameters")
@export var min_time_in_track_state: float = 3.0
@export var max_time_in_track_state: float = 5.0
@export var time_track_to_attack: float = 3.0
@export var player_is_near_threshold: float = 1.75

## States Enum
enum State {TRACK = 0, RAM_ATTACK = 1, BEAM_ATTACK = 2, DIVE_ATTACK = 3}
var state: State = State.TRACK

## State transition constants
const TRANS_TO_TRACK: String = "Behavior: to track"
const TRANS_TO_RAM_ATTACK: String = "Attack: to ram attack"
const TRANS_TO_BEAM_ATTACK: String = "Attack: to beam attack"
const TRANS_TO_DIVE_ATTACK: String = "Attack: to dive attack"

## Internal variables
var time_spent_in_track_state: float = 0.0


# track state
#----------------------------------------
func _on_track_state_entered() -> void:
	state = State.TRACK
	time_spent_in_track_state = 0.0


func _on_track_state_physics_processing(delta: float) -> void:
	time_spent_in_track_state += delta
	
	## If the player gets too close, immediately initiate a beam attack
	if _distance_to_player() < player_is_near_threshold:
		sc.send_event(TRANS_TO_BEAM_ATTACK)
	
	
	## If the drone is continuously tracking the player for a time, it initiates the attack
	if targeting_states.time_spent_in_acquired_state > time_track_to_attack and \
		time_spent_in_track_state > min_time_in_track_state:
		sc.send_event(pick_attack())
	
	## Max time to spend in track state before performing a ram attack, even if there wasn't
	## much time spent in acquired state. If target isn't aquired by that point, go to patrol
	if time_spent_in_track_state > max_time_in_track_state:
		if targeting_states.state == targeting_states.State.ACQUIRED:
			sc.send_event(pick_attack())
		else:
			sc.send_event(drone.behavior_states.TRANS_TO_GO_TO_PATROL)


# ram attack state
#----------------------------------------
func _on_ram_attack_state_entered() -> void:
	state = State.RAM_ATTACK


func _on_ram_attack_bt_state_exited() -> void:
	pass


func _on_ram_attack_bt_finished(status: int) -> void:
	match(status):
		BT.SUCCESS:
			sc.send_event(TRANS_TO_TRACK)
		BT.FAILURE:
			sc.send_event(TRANS_TO_TRACK)


# beam attack state
#----------------------------------------
func _on_beam_attack_state_entered() -> void:
	state = State.BEAM_ATTACK


func _on_beam_attack_bt_finished(status: int) -> void:
	match(status):
		BT.SUCCESS:
			sc.send_event(TRANS_TO_TRACK)
		BT.FAILURE:
			sc.send_event(TRANS_TO_TRACK)


# dive attack state
#----------------------------------------
func _on_dive_attack_state_entered() -> void:
	state = State.DIVE_ATTACK


func _on_dive_attack_bt_finished(status: int) -> void:
	match(status):
		BT.SUCCESS:
			sc.send_event(TRANS_TO_TRACK)
		BT.FAILURE:
			sc.send_event(TRANS_TO_TRACK)


# decision logic
#----------------------------------------
func _distance_to_player() -> float:
	return abs(drone.get_global_pos_x() - internal_representation.playerRepresentation.last_known_player_pos_x)


func pick_attack() -> String:
	if _distance_to_player() < player_is_near_threshold:
		return TRANS_TO_BEAM_ATTACK
	
	if internal_representation.playerRepresentation.player_is_dribbling:
		return TRANS_TO_BEAM_ATTACK
	
	return TRANS_TO_DIVE_ATTACK
