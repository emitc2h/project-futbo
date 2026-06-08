@tool
class_name ScoutOpenAction
extends BTAction

@export var quick: bool = false

## Internal References
var scout: Scout
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Progress gates
var is_finished: bool = false

func _generate_name() -> String:
	if quick:
		return "Quick OPEN"
	return "OPEN"


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	scout = agent as Scout
	scout.open_finished.connect(_on_open_finished)
	scout.quick_open_finished.connect(_on_quick_open_finished)


func _enter() -> void:
	signal_id = rng.randi()
	is_finished = false
	
	if quick:
		scout.quick_open(signal_id)
	else:
		scout.open(signal_id)


func _tick(_delta: float) -> Status:
	if not is_finished:
		return RUNNING
	else:
		return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_open_finished(id: int) -> void:
	if signal_id == id:
		is_finished = true


func _on_quick_open_finished(id: int) -> void:
	if signal_id == id:
		is_finished = true
