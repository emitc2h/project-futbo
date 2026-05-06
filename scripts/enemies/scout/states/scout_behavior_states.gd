class_name ScoutBehaviorStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart

@export_group("Parameters")
@export var transition_to_orbit_distance: float = 3.0

## States Enum
enum State {ENTRANCE = 0, ORBIT = 1, ACTION = 2}
var state: State = State.ENTRANCE

## State transition constants
const TRANS_TO_ORBIT: String = "Behavior: to orbit"
const TRANS_TO_ACTION: String = "Behavior: to action"


# entrance state
#----------------------------------------
func _on_entrance_state_entered() -> void:
	state = State.ENTRANCE
	scout.movement_states.set_player_as_out_of_plane_movement_target()
	sc.send_event(ScoutMovementStates.TRANS_TO_OUT_OF_PLANE_MOVEMENT)


func _on_entrance_state_physics_processing(_delta: float) -> void:
	var distance_to_player: float = scout.health_states.char_node.global_position.distance_to(Representations.player_target_marker.global_position)
	if distance_to_player < transition_to_orbit_distance:
		sc.send_event(TRANS_TO_ORBIT)


# orbit state
#----------------------------------------
func _on_orbit_state_entered() -> void:
	state = State.ORBIT
	sc.send_event(ScoutMovementStates.TRANS_TO_ORBITING)


# action state
#----------------------------------------
func _on_action_state_entered() -> void:
	state = State.ACTION
