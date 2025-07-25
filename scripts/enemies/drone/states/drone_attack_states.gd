class_name DroneAttackStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var behavior_states: DroneBehaviorStates
@export var targeting_states: DroneTargetingStates

@export_group("Parameters")
@export var min_time_in_track_state: float = 2.5
@export var max_time_in_track_state: float = 6.0
@export var time_track_to_ram_attack: float = 3.0

## States Enum
enum State {TRACK = 0, RAM_ATTACK = 1}
var state: State = State.TRACK

## State transition constants
const TRANS_RAM_ATTACK_TO_TRACK: String = "Behavior: ram attack to track"
const TRANS_TRACK_TO_RAM_ATTACK: String = "Attack: track to ram attack"

## Internal variables
var time_spent_in_track_state: float = 0.0


# track state
#----------------------------------------
func _on_track_state_entered() -> void:
	state = State.TRACK
	time_spent_in_track_state = 0.0


func _on_track_state_physics_processing(delta: float) -> void:
	time_spent_in_track_state += delta
	
	## If the drone is continuously tracking the player for a time, it initiates the attack
	if targeting_states.time_spent_in_acquired_state > time_track_to_ram_attack and \
		time_spent_in_track_state > min_time_in_track_state:
		sc.send_event(TRANS_TRACK_TO_RAM_ATTACK)
	
	## Max time to spend in track state before performing a ram attack
	if time_spent_in_track_state > max_time_in_track_state:
		sc.send_event(TRANS_TRACK_TO_RAM_ATTACK)

# ram attack state
#----------------------------------------
func _on_ram_attack_state_entered() -> void:
	state = State.RAM_ATTACK


func _on_ram_attack_state_exited() -> void:
	pass


func _on_ram_attack_bt_finished(status: int) -> void:
	match(status):
		BT.SUCCESS:
			sc.send_event(TRANS_RAM_ATTACK_TO_TRACK)
		BT.FAILURE:
			sc.send_event(TRANS_RAM_ATTACK_TO_TRACK)
