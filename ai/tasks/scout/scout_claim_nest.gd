@tool
class_name ScoutClaimNest
extends BTCondition

const CLAIM: String = "Claim"
const RELEASE: String = "Release"
const LEFT: String = "LEFT"
const RIGHT: String = "RIGHT"
const NEAREST: String = "NEAREST"

## Parameters
@export_enum(CLAIM, RELEASE) var action: String
@export_enum(LEFT, RIGHT, NEAREST) var nest: String

## Internal References
var scout: Scout

## Blackboard variables
@export var bb_nest_to_claim: StringName = &"nest_to_claim"


func _generate_name() -> String:
	return action + " " + nest + " nest"


func _setup() -> void:
	scout = agent as Scout


func _tick(_delta: float) -> Status:
	match(action):
		CLAIM:
			match(nest):
				LEFT:
					if scout.claim_nest(Enums.Direction.LEFT):
						return SUCCESS
					return FAILURE
				RIGHT:
					if scout.claim_nest(Enums.Direction.RIGHT):
						return SUCCESS
					return FAILURE
				NEAREST:
					return _claim_nearest_nest()
					
					
					
		RELEASE:
			scout.exit_nest()
			return SUCCESS
	return FAILURE


func _claim_nearest_nest() -> Status:
	var claimed_nest: Enums.Direction = scout.claim_nearest_nest()
	blackboard.set_var(bb_nest_to_claim, claimed_nest)
	match(claimed_nest):
		Enums.Direction.NONE:
			return FAILURE
		_:
			return SUCCESS
