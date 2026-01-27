class_name DroneBehaviorStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var cs: CompoundState

@export_group("BTPlayers")
@export var entrance_btplayer: BTPlayer
@export var idle_btplayer: BTPlayer
@export var combat_bt_player: BTPlayer

@export_group("State Mapping")
@export var state_map: Dictionary[State, StateChartState]

## States Enum
enum State {ENTRANCE = 0, IDLE = 1, COMBAT = 2, DISABLED = 3}
var state: State = State.DISABLED

## State transition constants
const TRANS_TO_ENTRANCE: String = "Behavior: to entrance"
const TRANS_TO_IDLE: String = "Behavior: to idle"
const TRANS_TO_COMBAT: String = "Behavior: to combat"
const TRANS_TO_DISABLED: String = "Behavior: to disabled"


# entrance state
#----------------------------------------
func _on_entrance_state_entered() -> void:
	state = State.ENTRANCE


# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	state = State.IDLE


# combat state
#----------------------------------------
func _on_combat_state_entered() -> void:
	state = State.COMBAT
	Signals.update_zoom.emit(Enums.Zoom.FAR)


func _on_combat_state_exited() -> void:
	Signals.update_zoom.emit(Enums.Zoom.DEFAULT)


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	state = State.DISABLED


##########################################
## SIGNALS                             ##
##########################################
func _on_entrance_behavior_tree_finished(status: int) -> void:
	if state == State.ENTRANCE and status == BT.SUCCESS:
		sc.send_event(TRANS_TO_IDLE)


func _on_idle_behavior_tree_finished(status: int) -> void:
	if state == State.IDLE and status == BT.FAILURE:
		sc.send_event(TRANS_TO_COMBAT)


func _on_combat_behavior_tree_finished(status: int) -> void:
	if state == State.COMBAT and status == BT.FAILURE:
		sc.send_event(TRANS_TO_IDLE)


##########################################
## CONTROLS                            ##
##########################################
func set_initial_state(new_initial_state: State) -> void:
	cs._initial_state = state_map[new_initial_state]


func enable(to_state: State = State.ENTRANCE) -> void:
	match(to_state):
		State.ENTRANCE:
			sc.send_event(TRANS_TO_ENTRANCE)
		State.IDLE:
			sc.send_event(TRANS_TO_IDLE)
		_:
			pass


func disable() -> void:
	sc.send_event(TRANS_TO_DISABLED)
