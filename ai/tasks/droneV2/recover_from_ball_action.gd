class_name RecoverFromBallAction
extends BTAction

var drone: DroneV2
var become_char_done: bool
var open_done: bool
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var signal_id: int

func _setup() -> void:
	drone = agent as DroneV2
	drone.physics_mode_states.char_entered.connect(_on_become_char_finished)
	drone.open_finished.connect(_on_open_finished)


func _enter() -> void:
	signal_id = rng.randi()
	become_char_done = false
	open_done = false
	drone.become_char()
	drone.open(signal_id)
	
	## Faciliate state recovery by checking if already in desired states
	if drone.physics_mode_states.state == drone.physics_mode_states.State.CHAR:
		become_char_done = true
	if drone.engagement_mode_states.state == drone.engagement_mode_states.State.OPEN:
		open_done = true


func _tick(delta: float) -> Status:
	if become_char_done and open_done:
		return SUCCESS
	return RUNNING


func _on_become_char_finished() -> void:
	become_char_done = true
	drone.enable_targeting(true)


func _on_open_finished(id: int) -> void:
	if signal_id == id:
		open_done = true
