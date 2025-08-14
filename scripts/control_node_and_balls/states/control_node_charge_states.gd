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
const TRANS_CHARGE_DOWN: String = "charge down"
const TRANS_DISCHARGE: String = "discharge"

## Nodes controlled
@onready var lose_charge_timer: Timer = $LoseChargeTimer

func _ready() -> void:
	rigid_node.body_entered.connect(_on_shield_body_entered)


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE
	asset.discharge()
	lose_charge_timer.stop()


# level1 state
#----------------------------------------
func _on_level_1_state_entered() -> void:
	state = State.LEVEL1
	asset.charge_level_1()
	lose_charge_timer.start()


# level2 state
#----------------------------------------
func _on_level_2_state_entered() -> void:
	state = State.LEVEL2
	asset.charge_level_2()
	lose_charge_timer.start()


# level3 state
#----------------------------------------
func _on_level_3_state_entered() -> void:
	state = State.LEVEL3
	asset.charge_level_3()
	asset.turn_on_ready_sphere()
	Signals.control_node_is_charged.emit()
	lose_charge_timer.start()


func _on_level_3_state_exited() -> void:
	asset.turn_off_ready_sphere()
	Signals.control_node_is_discharged.emit()


# signal handling
#========================================
func _on_shield_body_entered(body: Node) -> void:
	if body is DroneShield and control_node.power_states.in_on_state:
		sc.send_event(TRANS_CHARGE_UP)


func _on_lose_charge_timer_timeout() -> void:
	sc.send_event(TRANS_CHARGE_DOWN)
