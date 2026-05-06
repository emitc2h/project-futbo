class_name ScoutTargetingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart

@export_group("Parameters")
@export var targeting_max_range: float = 5.0


## States Enum
enum State {DISABLED = 0, NONE = 1, ACQUIRED = 2}
var state: State = State.DISABLED

## State transition constants
const TRANS_TO_DISABLED: String = "Targeting: to disabled"
const TRANS_TO_NONE: String = "Targeting: to none"
const TRANS_TO_ACQUIRED: String = "Targeting: to acquired"

## Settable Parameters
var target_candidate: Node3D
var target: Node3D


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	state = State.DISABLED


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE


func _on_none_state_physics_processing(_delta: float) -> void:
	var min_distance: float = targeting_max_range + 1.0
	target_candidate = null
	
	for potential_target in get_tree().get_nodes_in_group("ScoutTargetGroup"):
		if potential_target is Node3D:
			var distance: float = potential_target.global_position.distance_to(scout.physics_states.get_global_position())
			## If potential target is too far, rule it out
			if distance > targeting_max_range:
				continue
			
			## If the drone is NOT facing toward the potential target, rule it out
			if (potential_target.global_position.x - scout.physics_states.get_global_position().x) * scout.in_plane_movement_states.lerped_control_axis.x < 0.0:
				continue
			
			if distance < min_distance:
				target_candidate = potential_target
				min_distance = distance


# acquired state
#----------------------------------------
func _on_acquired_state_entered() -> void:
	state = State.ACQUIRED
	if target_candidate is CharacterBase:
		target = target_candidate.target_marker
	else:
		target = target_candidate


func _on_acquired_state_exited() -> void:
	target = null


# Controls
#========================================
func disable() -> void:
	sc.send_event(TRANS_TO_DISABLED)


func enable() -> void:
	if state == State.DISABLED:
		sc.send_event(TRANS_TO_NONE)


func lock_target() -> bool:
	if target_candidate:
		sc.send_event(TRANS_TO_ACQUIRED)
		return true
	return false


func release_target() -> void:
	if target:
		sc.send_event(TRANS_TO_NONE)
