class_name CharacterTargetingStates
extends CharacterStatesAbstractBase

@export var targeting_range: float = 10.0

## States Enum
enum State {NONE = 0, TARGETING = 1}
var state: State = State.NONE

## State transition constants
const TRANS_TO_NONE: String = "Targeting: to none"
const TRANS_TO_TARGETING: String = "Targeting: to targeting"

## Variables
var target: Node3D

## Not really used yet. I don't like the velocity/position correction idea to the kick force.


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE


# targeting state
#----------------------------------------
func _on_targeting_state_entered() -> void:
	state = State.TARGETING


#=======================================================
# UTILS
#=======================================================
func scan_for_nearest_enemy() -> void:
	
	var closest_distance: float = targeting_range + 1000.0
	var closest_enemy: Node3D
	
	var face_sign: float = character.direction_states.face_sign()
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		var distance: float = character.global_position.x - enemy.char_node.global_position.x
		var abs_distance: float = abs(distance)
		
		## If the enemy is farther away than the targeting range, rule it out
		if abs_distance > targeting_range:
			continue
		
		## If the player isn't facing this enemy, rule it out
		if distance * face_sign > 0:
			continue
		
		if abs_distance < closest_distance:
			closest_distance = abs_distance
			closest_enemy = enemy
	
	if closest_enemy and not state == State.TARGETING:
		target = closest_enemy
		sc.send_event(TRANS_TO_TARGETING)
		return
	
	if not closest_enemy and not state == State.NONE:
		target = null
		sc.send_event(TRANS_TO_NONE)
		return
