class_name ScoutBehaviorStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart

@onready var time_to_action_timer: Timer = $TimeToActionTimer

@export_group("BTPlayers")
@export var action_bt_player: BTPlayer

@export_group("Parameters")
@export var transition_to_orbit_distance: float = 3.0
@export var min_time_to_action: float = 2.0
@export var max_time_to_action: float = 4.0

## States Enum
enum State {GO_TO_PLAYER = 0, ORBIT = 1, ACTION = 2}
var state: State = State.GO_TO_PLAYER

## State transition constants
const TRANS_TO_GO_TO_PLAYER: String = "Behavior: go to player"
const TRANS_TO_ORBIT: String = "Behavior: to orbit"
const TRANS_TO_ACTION: String = "Behavior: to action"


# entrance state
#----------------------------------------
func _on_go_to_player_state_entered() -> void:
	state = State.GO_TO_PLAYER
	scout.movement_states.set_player_as_out_of_plane_movement_target()
	sc.send_event(ScoutMovementStates.TRANS_TO_OUT_OF_PLANE_MOVEMENT)


func _on_go_to_player_state_physics_processing(_delta: float) -> void:
	var distance_to_player: float = scout.health_states.char_node.global_position.distance_to(Representations.player_target_marker.global_position)
	if distance_to_player < transition_to_orbit_distance:
		scout.orbiting_states.set_initial_state(ScoutOrbitingStates.State.TARGETING)
		sc.send_event(TRANS_TO_ORBIT)


# orbit state
#----------------------------------------
func _on_orbit_state_entered() -> void:
	state = State.ORBIT
	sc.send_event(ScoutMovementStates.TRANS_TO_ORBITING)
	
	var time_to_action: float = randf_range(min_time_to_action, max_time_to_action)
	time_to_action_timer.wait_time = time_to_action
	time_to_action_timer.start()


# action state
#----------------------------------------
func _on_action_state_entered() -> void:
	state = State.ACTION


##########################################
## SIGNALS                             ##
##########################################
func _on_action_bt_player_behavior_tree_finished(status: int) -> void:
	if status == BT.SUCCESS:
		scout.orbiting_states.set_initial_state(ScoutOrbitingStates.State.LOOPING)
	else:
		scout.orbiting_states.set_initial_state(ScoutOrbitingStates.State.TARGETING)
	sc.send_event(TRANS_TO_ORBIT)


func _on_time_to_action_timer_timeout() -> void:
	time_to_action_timer.stop()
	sc.send_event(TRANS_TO_ACTION)
