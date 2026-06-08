@tool
class_name ScoutGoToNestAction
extends BTAction

const LEFT: String = "LEFT"
const RIGHT: String = "RIGHT"
const NEAREST: String = "NEAREST"

## Parameters
@export_enum(LEFT, NEAREST, RIGHT) var nest: String

## Internal References
var scout: Scout
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Blackboard variables
@export var bb_nest_to_claim: StringName = &"nest_to_claim"

## Progress gates
var is_in_nest: bool = false

func _generate_name() -> String:
	return "Go to " + nest + " nest"


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	scout = agent as Scout
	scout.go_to_nest_finished.connect(_on_go_to_nest_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	scout.quick_close()
	signal_id = rng.randi()
	
	match(nest):
		LEFT:
			scout.go_to_nest(Enums.Direction.LEFT, signal_id)
		RIGHT:
			scout.go_to_nest(Enums.Direction.RIGHT, signal_id)
		NEAREST:
			var nearest_nest: Enums.Direction = blackboard.get_var(bb_nest_to_claim)
			assert(nearest_nest != Enums.Direction.NONE, "ScoutGoToNestAction has received NONE as nearest nest")
			scout.go_to_nest(nearest_nest, signal_id)
	
	is_in_nest = false


func _tick(_delta: float) -> Status:
	if not is_in_nest:
		return RUNNING
		
	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_go_to_nest_finished(id: int) -> void:
	if signal_id == id:
		is_in_nest = true
