extends Node

## This could be improved by only updating when scout events happen, although it would be a lot harder to track
## and debug.
func _physics_process(_delta: float) -> void:
	var num_scouts: int = 0
	var num_incapacitated_scouts: int = 0
	var num_scouts_in_gameplay_plane: int = 0

	for node in get_tree().get_nodes_in_group("ScoutHivemindGroup"):
		var scout: Scout = node as Scout
		num_scouts += 1
		if scout.health_states.state == ScoutHealthStates.State.INCAPACITATED:
			num_incapacitated_scouts += 1
		if scout.movement_states.state == ScoutMovementStates.State.IN_PLANE_MOVEMENT\
			or scout.movement_states.state == ScoutMovementStates.State.ENTER_PLANE:
			num_scouts_in_gameplay_plane += 1
	
	Representations.scout_hivemind_representation = ScoutHivemindRepresentation.new(
		num_scouts,
		Representations.scout_hivemind_representation.scout_is_in_left_nest,
		Representations.scout_hivemind_representation.scout_is_in_right_nest,
		num_scouts_in_gameplay_plane,
		num_incapacitated_scouts
	)
