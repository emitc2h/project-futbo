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

## TRANS_ANIM constants
const CHARGE_LEVEL_0_STATE_ANIM: String = "state - power on - charge level 0"
const CHARGE_LEVEL_0_EXPANDED_STATE_ANIM: String = "state - power on - charge level 0 - expanded"
const CHARGE_LEVEL_1_STATE_ANIM: String = "state - power on - charge level 1"
const CHARGE_LEVEL_1_EXPANDED_STATE_ANIM: String = "state - power on - charge level 1 - expanded"
const CHARGE_LEVEL_2_STATE_ANIM: String = "state - power on - charge level 2"
const CHARGE_LEVEL_2_EXPANDED_STATE_ANIM: String = "state - power on - charge level 2 - expanded"
const CHARGE_LEVEL_3_STATE_ANIM: String = "state - power on - charge level 3"
const CHARGE_LEVEL_3_EXPANDED_STATE_ANIM: String = "state - power on - charge level 3 - expanded"

const HIT_LEVEL1_TRANS_ANIM: String = "transition - hit - charge level 1 - expanded"
const HIT_LEVEL2_TRANS_ANIM: String = "transition - hit - charge level 2 - expanded"
const HIT_LEVEL3_TRANS_ANIM: String = "transition - hit - charge level 3 - expanded"

## Nodes controlled
@onready var lose_charge_timer: Timer = $LoseChargeTimer

## Internal variables
var none_state_anim: String = CHARGE_LEVEL_0_STATE_ANIM
var lvl1_state_anim: String = CHARGE_LEVEL_1_STATE_ANIM
var lvl2_state_anim: String = CHARGE_LEVEL_2_STATE_ANIM
var lvl3_state_anim: String = CHARGE_LEVEL_3_STATE_ANIM

func _ready() -> void:
	rigid_node.body_entered.connect(_on_shield_body_entered)
	Signals.player_shield_taking_charges.connect(_on_player_shield_taking_charges)


# none state
#----------------------------------------
func _on_none_state_entered() -> void:
	state = State.NONE
	Signals.updated_control_node_charge_level.emit(state)
	control_node.anim_state.travel(none_state_anim)
	none_state_anim = CHARGE_LEVEL_0_STATE_ANIM
	lose_charge_timer.stop()
	
	Representations.control_node_representation.shield_charges = 0


# level1 state
#----------------------------------------
func _on_level_1_state_entered() -> void:
	state = State.LEVEL1
	Signals.updated_control_node_charge_level.emit(state)
	control_node.anim_state.travel(lvl1_state_anim)
	lvl1_state_anim = CHARGE_LEVEL_1_STATE_ANIM
	lose_charge_timer.start()
	
	Representations.control_node_representation.shield_charges = 1


# level2 state
#----------------------------------------
func _on_level_2_state_entered() -> void:
	state = State.LEVEL2
	Signals.updated_control_node_charge_level.emit(state)
	control_node.anim_state.travel(lvl2_state_anim)
	lvl2_state_anim = CHARGE_LEVEL_2_STATE_ANIM
	lose_charge_timer.start()
	
	Representations.control_node_representation.shield_charges = 2


# level3 state
#----------------------------------------
func _on_level_3_state_entered() -> void:
	state = State.LEVEL3
	Signals.updated_control_node_charge_level.emit(state)
	control_node.anim_state.travel(lvl3_state_anim)
	lvl3_state_anim = CHARGE_LEVEL_3_STATE_ANIM
	Signals.control_node_is_charged.emit()
	lose_charge_timer.start()
	
	Representations.control_node_representation.shield_charges = 3


func _on_level_3_state_exited() -> void:
	Signals.control_node_is_discharged.emit()


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_shield_body_entered(body: Node) -> void:
	if body is DroneShield:
		sc.send_event(TRANS_CHARGE_UP)


func _on_lose_charge_timer_timeout() -> void:
	sc.send_event(TRANS_CHARGE_DOWN)


func _on_animation_state_finished(anim_name: String) -> void:
	match(anim_name):
		HIT_LEVEL1_TRANS_ANIM:
			sc.send_event(TRANS_CHARGE_DOWN)
		HIT_LEVEL2_TRANS_ANIM:
			sc.send_event(TRANS_CHARGE_DOWN)
		HIT_LEVEL3_TRANS_ANIM:
			sc.send_event(TRANS_CHARGE_DOWN)


func _on_player_shield_taking_charges(num_charges_taken: int) -> void:
	for i in num_charges_taken:
		sc.send_event(TRANS_CHARGE_DOWN)

#=======================================================
# ANIMATION UTILS
#=======================================================
func lose_charge_by_hit_anim() -> void:
	none_state_anim = CHARGE_LEVEL_0_EXPANDED_STATE_ANIM
	lvl1_state_anim = CHARGE_LEVEL_1_EXPANDED_STATE_ANIM
	lvl2_state_anim = CHARGE_LEVEL_2_EXPANDED_STATE_ANIM
	lvl3_state_anim = CHARGE_LEVEL_3_EXPANDED_STATE_ANIM
	match(state):
		State.LEVEL1:
			control_node.anim_state.travel(HIT_LEVEL1_TRANS_ANIM)
		State.LEVEL2:
			control_node.anim_state.travel(HIT_LEVEL2_TRANS_ANIM)
		State.LEVEL3:
			control_node.anim_state.travel(HIT_LEVEL3_TRANS_ANIM)


#=======================================================
# UTILS
#=======================================================
func num_charges() -> int:
	return state as int
