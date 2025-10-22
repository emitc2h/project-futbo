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

## internal variables
var blow_factor: float = 3.0

func _ready() -> void:
	rigid_node.body_entered.connect(_on_shield_body_entered)
	Signals.control_node_shield_hit.connect(_on_control_node_shield_hit)


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE
	Signals.updated_control_node_charge_level.emit(state)
	asset.shield_anim.animate_to_state(state, control_node.shield_states.state, 0.4, blow_factor)
	lose_charge_timer.stop()
	## Reset blow factor
	blow_factor = 3.0


# level1 state
#----------------------------------------
func _on_level_1_state_entered() -> void:
	state = State.LEVEL1
	Signals.updated_control_node_charge_level.emit(state)
	asset.shield_anim.animate_to_state(state, control_node.shield_states.state, 0.4, blow_factor)
	lose_charge_timer.start()


# level2 state
#----------------------------------------
func _on_level_2_state_entered() -> void:
	state = State.LEVEL2
	Signals.updated_control_node_charge_level.emit(state)
	asset.shield_anim.animate_to_state(state, control_node.shield_states.state, 0.4, blow_factor)
	lose_charge_timer.start()


# level3 state
#----------------------------------------
func _on_level_3_state_entered() -> void:
	state = State.LEVEL3
	Signals.updated_control_node_charge_level.emit(state)
	asset.shield_anim.animate_to_state(state, control_node.shield_states.state, 0.4, blow_factor)
	asset.turn_on_ready_sphere()
	Signals.control_node_is_charged.emit()
	lose_charge_timer.start()


func _on_level_3_state_exited() -> void:
	asset.turn_off_ready_sphere()
	Signals.control_node_is_discharged.emit()


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_shield_body_entered(body: Node) -> void:
	if body is DroneShield:
		sc.send_event(TRANS_CHARGE_UP)


func _on_lose_charge_timer_timeout() -> void:
	sc.send_event(TRANS_CHARGE_DOWN)


func _on_control_node_shield_hit(one_hit: bool) -> void:
	blow_factor = 10.0
	## Check state before discharging, otherwise the state is always NONE
	if state == State.NONE or one_hit:
		sc.send_event(TRANS_DISCHARGE)
		sc.send_event(control_node.power_states.TRANS_TO_BLOW)
	else:
		sc.send_event(TRANS_DISCHARGE)
