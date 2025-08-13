class_name ControlNode
extends Ball

## Overrides
var control_node_control_states: ControlNodeControlStates

@export_group("Control Node State Machines")
@export var power_states: ControlNodePowerStates
@export var charge_states: ControlNodeChargeStates


func _ready() -> void:
	control_node_control_states = control_states as ControlNodeControlStates

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
