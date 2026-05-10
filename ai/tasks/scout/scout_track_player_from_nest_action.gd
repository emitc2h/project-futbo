class_name ScoutTrackPlayerFromNestAction
extends BTAction

## Parameters
@export var duration: float = 4.0
@export var approach_distance: float = 1.0

## Internal References
var scout: Scout
var time_elapsed: float = 0.0


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	scout = agent as Scout


func _enter() -> void:
	time_elapsed = 0.0


func _tick(delta: float) -> Status:
	## Exit when the duration has been exceeded
	time_elapsed += delta
	if time_elapsed > duration:
		return SUCCESS
	
	var nest_position: Vector2 = Vector2(
		Representations.player_target_marker.global_position.x + scout.movement_states.player_target_offset_x,
		Representations.player_target_marker.global_position.y + scout.movement_states.player_target_offset_y
		)
	
	var char_node_position: Vector2 = Vector2(
		scout.movement_states.char_node.global_position.x,
		scout.movement_states.char_node.global_position.y
	)
	
	var distance: float = nest_position.distance_to(char_node_position)
	var control_magnitude: float = min(approach_distance, distance) / approach_distance
	
	var direction: Vector2 = (nest_position - char_node_position).normalized()
	
	scout.in_plane_movement_states.control_axis = direction * control_magnitude
		
	return RUNNING
