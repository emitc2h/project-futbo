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
		RELEASE:
			scout.exit_nest()
			return SUCCESS
	return FAILURE
