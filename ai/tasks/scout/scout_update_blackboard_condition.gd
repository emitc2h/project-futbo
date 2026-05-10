class_name ScoutUpdateBlackboardCondition
extends BTCondition

@export var scout_hivemind_num_scouts: StringName = &"scout_hivemind_num_scouts"
@export var scout_hivemind_scout_is_in_left_nest: StringName = &"scout_hivemind_scout_is_in_left_nest"
@export var scout_hivemind_scout_is_in_right_nest: StringName = &"scout_hivemind_scout_is_in_right_nest"
@export var scout_hivemind_num_scouts_in_gameplay_plane: StringName = &"scout_hivemind_num_scouts_in_gameplay_plane"
@export var scout_hivemind_num_incapacitated_scouts: StringName = &"scout_hivemind_num_incapacitated_scouts"


func _enter() -> void:
	blackboard.set_var(scout_hivemind_num_scouts, Representations.scout_hivemind_representation.num_incapacitated_scouts)
	blackboard.set_var(scout_hivemind_scout_is_in_left_nest, Representations.scout_hivemind_representation.scout_is_in_left_nest)
	blackboard.set_var(scout_hivemind_scout_is_in_right_nest, Representations.scout_hivemind_representation.scout_is_in_right_nest)
	blackboard.set_var(scout_hivemind_num_scouts_in_gameplay_plane, Representations.scout_hivemind_representation.num_scouts_in_gameplay_plane)
	blackboard.set_var(scout_hivemind_num_incapacitated_scouts, Representations.scout_hivemind_representation.num_incapacitated_scouts)


func _tick(_delta: float) -> Status:
	return SUCCESS
