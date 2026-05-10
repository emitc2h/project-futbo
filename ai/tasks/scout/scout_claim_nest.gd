@tool
class_name ScoutClaimNest
extends BTCondition

const CLAIM: String = "Claim"
const RELEASE: String = "Release"
const LEFT: String = "LEFT"
const RIGHT: String = "RIGHT"

## Parameters
@export_enum(CLAIM, RELEASE) var action: String
@export_enum(LEFT, RIGHT) var nest: String

## Internal References
var scout: Scout


func _generate_name() -> String:
	return action + " " + nest + " nest"


func _setup() -> void:
	scout = agent as Scout


func _tick(_delta: float) -> Status:
	if action == CLAIM:
		match(nest):
			LEFT:
				if Representations.scout_hivemind_representation.scout_is_in_left_nest:
					return FAILURE
				else:
					Representations.scout_hivemind_representation.scout_is_in_left_nest = true
					return SUCCESS
			RIGHT:
				if Representations.scout_hivemind_representation.scout_is_in_right_nest:
					return FAILURE
				else:
					Representations.scout_hivemind_representation.scout_is_in_right_nest = true
					return SUCCESS
	else:
		## Ideally I would check that the same scout who clamed the nest is also the one release it
		match(nest):
			LEFT:
				Representations.scout_hivemind_representation.scout_is_in_left_nest = false
				return SUCCESS
			RIGHT:
				Representations.scout_hivemind_representation.scout_is_in_right_nest = false
				return SUCCESS
	return FAILURE
