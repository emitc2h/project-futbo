class_name ScoutBeamAttackAction
extends BTAction

## Internal References
var scout: Scout
var signal_id: int
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

## Progress gates
var is_finished: bool = false


##########################################
## ACTION LOGIC                        ##
##########################################
func _setup() -> void:
	scout = agent as Scout
	scout.fire_finished.connect(_on_fire_finished)


func _enter() -> void:
	signal_id = rng.randi()
	is_finished = false
	
	scout.fire(signal_id)


func _tick(_delta: float) -> Status:
	if not is_finished:
		return RUNNING
	else:
		return SUCCESS


##########################################
## SIGNALS                             ##
##########################################
func _on_fire_finished(id: int) -> void:
	if signal_id == id:
		is_finished = true
