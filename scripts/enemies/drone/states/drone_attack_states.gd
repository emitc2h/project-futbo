class_name DroneAttackStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: DroneV2
@export var sc: StateChart
@export var behavior_states: DroneBehaviorStates
@export var targeting_states: DroneTargetingStates

## States Enum
enum State {TRACK = 0, RAM_ATTACK = 1}
var state: State = State.TRACK

## State transition constants
const TRANS_RAM_ATTACK_TO_TRACK: String = "Behavior: ram attack to track"
const TRANS_TRACK_TO_RAM_ATTACK: String = "Attack: track to ram attack"


func _ready() -> void:
	targeting_states.target_none.connect(_on_target_none)


# track state
#----------------------------------------
func _on_track_state_entered() -> void:
	state = State.TRACK
	await get_tree().create_timer(4.0).timeout
	sc.send_event(TRANS_TRACK_TO_RAM_ATTACK)


# ram attack state
#----------------------------------------
func _on_ram_attack_state_entered() -> void:
	state = State.RAM_ATTACK


func _on_ram_attack_state_exited() -> void:
	pass


func _on_ram_attack_bt_finished(status: int) -> void:
	sc.send_event(TRANS_RAM_ATTACK_TO_TRACK)


# signal handling
#========================================
func _on_target_none() -> void:
	if state == State.TRACK:
		sc.send_event(behavior_states.TRANS_ATTACK_TO_GO_TO_PATROL)
