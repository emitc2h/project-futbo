class_name DroneBehaviorStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var vulnerabiliy_states: DroneVulnerabilityStates

@export_group("Monitoring State Machines")
@export var targeting_states: DroneTargetingStates
@export var proximity_states: DroneProximityStates
@export var position_states: DronePositionStates

@export_group("Behavior sub-state machines")
@export var attack_states: DroneAttackStates

## States Enum
enum State {PATROL = 0, GO_TO_PATROL = 1, SEEK = 2, BLOCK = 3, SLEEP = 4, ATTACK = 5}
var state: State = State.PATROL

## State transition constants
const TRANS_PATROL_TO_ATTACK: String = "Behavior: patrol to attack"
const TRANS_PATROL_TO_BLOCK: String = "Behavior: patrol to block"

const TRANS_GO_TO_PATROL_TO_PATROL: String = "Behavior: go to patrol to patrol"
const TRANS_GO_TO_PATROL_TO_ATTACK: String = "Behavior: go to patrol to attack"
const TRANS_GO_TO_PATROL_TO_BLOCK: String = "Behavior: go to patrol to block"

const TRANS_BLOCK_TO_ATTACK: String = "Behavior: block to attack"

const TRANS_ATTACK_TO_GO_TO_PATROL: String = "Behavior: attack to go to patrol"
const TRANS_ATTACK_TO_BLOCK: String = "Behavior: attack to block"


func _ready() -> void:
	targeting_states.target_none.connect(_on_target_none)
	targeting_states.target_acquired.connect(_on_target_acquired)
	proximity_states.control_node_proximity_entered.connect(_on_control_node_proximity_entered)
	proximity_states.player_proximity_entered.connect(_on_player_proximity_entered)


# patrol state
#----------------------------------------
func _on_patrol_state_entered() -> void:
	state = State.PATROL
	
	## Zoom back in
	Signals.update_zoom.emit(Enums.Zoom.DEFAULT)


# go to patrol state
#----------------------------------------
func _on_go_to_patrol_state_entered() -> void:
	state = State.GO_TO_PATROL
	if position_states.state == position_states.State.BETWEEN_PATROL_MARKERS:
		sc.send_event(TRANS_GO_TO_PATROL_TO_PATROL)
	
	## Zoom back in
	Signals.update_zoom.emit(Enums.Zoom.DEFAULT)


func _on_go_to_patrol_bt_finished(status: int) -> void:
	sc.send_event(TRANS_GO_TO_PATROL_TO_PATROL)


# seek state
#----------------------------------------
func _on_seek_state_entered() -> void:
	state = State.SEEK


# block state
#----------------------------------------
func _on_block_state_entered() -> void:
	state = State.BLOCK


func _on_block_bt_finished(status: int) -> void:
	sc.send_event(TRANS_BLOCK_TO_ATTACK)


# attack state
#----------------------------------------
func _on_attack_state_entered() -> void:
	state = State.ATTACK
	sc.send_event(attack_states.TRANS_RAM_ATTACK_TO_TRACK)
	
	## Zoom out
	Signals.update_zoom.emit(Enums.Zoom.FAR)


# signal handling
#========================================
func _on_target_none() -> void:
	if state == State.ATTACK:
		sc.send_event(TRANS_ATTACK_TO_GO_TO_PATROL)

func _on_target_acquired() -> void:
	## If the drone sees the player, go to attack state
	if state == State.PATROL:
		sc.send_event(TRANS_PATROL_TO_ATTACK)
	if state == State.GO_TO_PATROL:
		sc.send_event(TRANS_GO_TO_PATROL_TO_ATTACK)


func _on_control_node_proximity_entered(control_node: ControlNode) -> void:
	## If the drone doesn't already have a target, use the control node
	if not targeting_states.target:
		targeting_states.target = control_node.physics_states.track_position_container
	
	## If the control node is detected within the proximity detector, go to block state
	if vulnerabiliy_states.state == vulnerabiliy_states.State.DEFENDABLE:
		if state == State.PATROL:
			sc.send_event(TRANS_PATROL_TO_BLOCK)
		if state == State.GO_TO_PATROL:
			sc.send_event(TRANS_GO_TO_PATROL_TO_BLOCK)
		if state == State.ATTACK:
			sc.send_event(TRANS_ATTACK_TO_BLOCK)


func _on_player_proximity_entered() -> void:
	## If the the player is detected within the proximity detector, go to attack state
	if state == State.PATROL:
		sc.send_event(TRANS_PATROL_TO_ATTACK)
	if state == State.GO_TO_PATROL:
		sc.send_event(TRANS_GO_TO_PATROL_TO_ATTACK)
