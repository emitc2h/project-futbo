class_name ScoutMovementStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart

## States Enum
enum State {IN_PLANE_MOVEMENT = 0, ENTERING_ORBIT = 1, ORBITING = 2, LEAVING_ORBIT = 3}
var state: State = State.IN_PLANE_MOVEMENT

## State transition constants
const TRANS_TO_IN_PLANE_MOVEMENT: String = "Movement: to in plane movement"
const TRANS_TO_ENTERING_ORBIT: String = "Movement: to entering orbit"
const TRANS_TO_ORBITING: String = "Movement: to orbiting"
const TRANS_TO_LEAVING_ORBIT: String = "Movement: to leaving orbit"

# in plane movement state
#----------------------------------------
func _on_in_plane_movement_state_entered() -> void:
	state = State.IN_PLANE_MOVEMENT


# entering orbit state
#----------------------------------------
func _on_entering_orbit_state_entered() -> void:
	state = State.ENTERING_ORBIT


# orbiting state
#----------------------------------------
func _on_orbiting_state_entered() -> void:
	state = State.ORBITING


# leaving orbit state
#----------------------------------------
func _on_leaving_orbit_state_entered() -> void:
	state = State.LEAVING_ORBIT
