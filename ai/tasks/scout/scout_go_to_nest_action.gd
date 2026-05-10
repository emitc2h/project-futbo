@tool
class_name ScoutGoToNestAction
extends BTAction

const LEFT: String = "LEFT"
const RIGHT: String = "RIGHT"

## Parameters
@export_enum(LEFT, RIGHT) var nest: String

## Internal References
var scout: Scout
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Progress gates
var is_in_nest: bool = false
var is_opening: bool = false
var is_opened: bool = false


func _generate_name() -> String:
	return "Go to " + nest + " nest"

##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	scout = agent as Scout
	scout.go_to_nest_finished.connect(_on_go_to_nest_finished)
	scout.open_finished.connect(_on_open_finished)


func _enter() -> void:
	## reset the signal ID to make sure old signals don't mess up re-entry into this action
	scout.quick_close()
	signal_id = rng.randi()
	
	match(nest):
		LEFT:
			scout.go_to_nest(Enums.Direction.LEFT, signal_id)
		RIGHT:
			scout.go_to_nest(Enums.Direction.RIGHT, signal_id)
	
	is_in_nest = false
	is_opened = false
	is_opening = false


func _tick(_delta: float) -> Status:
	if not is_in_nest:
		return RUNNING
	
	if not is_opened:
		if not is_opening:
			scout.open(signal_id)
			is_opening = true
		return RUNNING
		
	return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_go_to_nest_finished(id: int) -> void:
	if signal_id == id:
		is_in_nest = true


func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_opened = true
