class_name ControlNode
extends Ball

## Overrides
var control_node_control_states: ControlNodeControlStates

@export_group("Control Node State Machines")
@export var power_states: ControlNodePowerStates
@export var charge_states: ControlNodeChargeStates

@export_group("Assets")
@export var asset: ControlNodeAsset

func _ready() -> void:
	control_node_control_states = control_states as ControlNodeControlStates
	Signals.player_long_kick_ready.connect(_on_player_long_kick_ready)

#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func long_kick(force_vector: Vector3) -> void:
	if charge_states.state == charge_states.State.LEVEL3:
		control_node_control_states.shot_vector = force_vector
		sc.send_event(control_node_control_states.TRANS_FREE_TO_SHOT)
	else:
		super.long_kick(force_vector)


func blow() -> void:
	sc.send_event(power_states.TRANS_BLOW)


# Signal handling
# ===========================================
func _on_player_long_kick_ready() -> void:
	print("long kick ready received")
	if charge_states.state == charge_states.State.LEVEL3:
		asset.magenta_wisps()
