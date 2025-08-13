class_name ControlNodeChargeStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var control_node: ControlNode
@export var rigid_node: InertNode
@export var asset: ControlNodeAsset
@export var sc: StateChart

## States Enum
enum State {NONE = 0, LEVEL1 = 1, LEVEL2 = 2, LEVEL3 = 3}
var state: State = State.NONE

## State transition constants
const TRANS_CHARGE_UP: String = "charge up"
const TRANS_DISCHARGE: String = "discharge"

func _ready() -> void:
	rigid_node.body_entered.connect(_on_shield_body_entered)


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE
	asset.discharge()


# level1 state
#----------------------------------------
func _on_level_1_state_entered() -> void:
	state = State.LEVEL1
	asset.charge_level_1()


# level2 state
#----------------------------------------
func _on_level_2_state_entered() -> void:
	state = State.LEVEL2
	asset.charge_level_2()


# level3 state
#----------------------------------------
func _on_level_3_state_entered() -> void:
	state = State.LEVEL3
	asset.charge_level_3()
	asset.turn_on_ready_sphere()
	Signals.control_node_is_charged.emit()


func _on_level_3_state_exited() -> void:
	asset.turn_off_ready_sphere()
	Signals.control_node_is_discharged.emit()


# signal handling
#========================================
func _on_shield_body_entered(body: Node) -> void:
	if body is DroneShield and control_node.power_states.in_on_state:
		sc.send_event(TRANS_CHARGE_UP)
