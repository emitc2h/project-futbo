class_name ControlNodeShieldStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var control_node: ControlNode
@export var asset: ControlNodeAsset
@export var sc: StateChart
@export var shield_collision: StaticBody3D

## States Enum
enum State {OFF = 0, EXPANDING = 1, ON = 2, DISSIPATING = 3}
var state: State = State.OFF

## State transition constants
const TRANS_TO_OFF: String = "Shield: to off"
const TRANS_TO_EXPANDING: String = "Shield: to expanding"
const TRANS_TO_ON: String = "Shield: to on"
const TRANS_TO_DISSIPATING: String = "Shield: to dissipating"

## Animation constants
const EXPAND_LEVEL_0_TRANS_ANIM: String = "transition - power on - charge level 0 - expanding"
const EXPAND_LEVEL_1_TRANS_ANIM: String = "transition - power on - charge level 1 - expanding"
const EXPAND_LEVEL_2_TRANS_ANIM: String = "transition - power on - charge level 2 - expanding"
const EXPAND_LEVEL_3_TRANS_ANIM: String = "transition - power on - charge level 3 - expanding"

const DISSIPATE_LEVEL_0_TRANS_ANIM: String = "transition - power on - charge level 0 - dissipating"
const DISSIPATE_LEVEL_1_TRANS_ANIM: String = "transition - power on - charge level 1 - dissipating"
const DISSIPATE_LEVEL_2_TRANS_ANIM: String = "transition - power on - charge level 2 - dissipating"
const DISSIPATE_LEVEL_3_TRANS_ANIM: String = "transition - power on - charge level 3 - dissipating"

## Internal variables
var _intends_to_shield: bool = false
var _player_is_idle: bool = false
var _player_is_dribbling: bool = false
var _shield_allowed: bool = true


func _ready() -> void:
	Signals.idle_entered.connect(_on_player_idle_entered)
	Signals.idle_exited.connect(_on_player_idle_exited)
	Signals.dribbling_entered.connect(_on_player_dribbling_entered)
	Signals.dribbling_exited.connect(_on_player_dribbling_exited)
	Signals.player_moved.connect(_on_player_moved)
	control_node.power_states.control_node_power_is_on.connect(_on_power_is_on)
	
	## Disable the shield collision shape by default
	shield_collision.set_collision_layer_value(6, false)


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	
	## Re-enable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = true
	
	Representations.control_node_representation.shield_expanded = false
	
	## Shield being off means charge 0, 1 and 2 should reflect the non-expanded state after hit
	control_node.charge_states.set_shield_state_anim(false)


# inflating state
#----------------------------------------
func _on_expanding_state_entered() -> void:
	state = State.EXPANDING
	
	## Shield expanding means charge 0, 1 and 2 should reflect the expanded state after hit
	control_node.charge_states.set_shield_state_anim(true)
	
	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false
	
	expand_animation()


# on state
#----------------------------------------
func _on_on_state_entered() -> void:
	state = State.ON
	
	## Shield being on means charge 0, 1 and 2 should reflect the expanded state after hit
	control_node.charge_states.set_shield_state_anim(true)
	
	shield_collision.set_collision_layer_value(6, true)
	
	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false
	
	Representations.control_node_representation.shield_expanded = true


func _on_on_state_exited() -> void:
	shield_collision.set_collision_layer_value(6, false)


# dissipating state
#----------------------------------------
func _on_dissipating_state_entered() -> void:
	state = State.DISSIPATING
	
	## Dissipating the shield means charge 0, 1 and 2 should reflect the non-expanded state
	control_node.charge_states.set_shield_state_anim(false)
	
	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false
	
	
	dissipate_animation()


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_player_idle_entered() -> void:
	_player_is_idle = true
	check_conditions_to_shield()


func _on_player_idle_exited() -> void:
	_player_is_idle = false
	sc.send_event(TRANS_TO_DISSIPATING)


func _on_player_dribbling_entered() -> void:
	_player_is_dribbling = true
	check_conditions_to_shield()


func _on_player_dribbling_exited() -> void:
	_player_is_dribbling = false
	sc.send_event(TRANS_TO_DISSIPATING)


func _on_player_moved() -> void:
	sc.send_event(TRANS_TO_DISSIPATING)


func _on_power_is_on() -> void:
	check_conditions_to_shield()


func _on_animation_state_started(anim_name: String) -> void:
	## This could be unreliable, I have to thoroughly test it
	match(anim_name):
		## Broadcast the number of charges available to transfer to the personal shield
		DISSIPATE_LEVEL_0_TRANS_ANIM, DISSIPATE_LEVEL_1_TRANS_ANIM,\
		DISSIPATE_LEVEL_2_TRANS_ANIM, DISSIPATE_LEVEL_3_TRANS_ANIM:
			Signals.control_node_shield_dissipating.emit(control_node.charge_states.num_charges())


func _on_animation_state_finished(anim_name: String) -> void:
	match(anim_name):
		EXPAND_LEVEL_0_TRANS_ANIM, EXPAND_LEVEL_1_TRANS_ANIM,\
		 EXPAND_LEVEL_2_TRANS_ANIM, EXPAND_LEVEL_3_TRANS_ANIM:
			sc.send_event(TRANS_TO_ON)
		DISSIPATE_LEVEL_0_TRANS_ANIM, DISSIPATE_LEVEL_1_TRANS_ANIM,\
		 DISSIPATE_LEVEL_2_TRANS_ANIM, DISSIPATE_LEVEL_3_TRANS_ANIM:
			sc.send_event(TRANS_TO_OFF)


#=======================================================
# CONTROLS
#=======================================================
func check_conditions_to_shield() -> void:
	_shield_allowed = _player_is_idle and _player_is_dribbling and _intends_to_shield
	## If all conditions are met
	if _shield_allowed:
		sc.send_event(TRANS_TO_EXPANDING)
	else:
		sc.send_event(TRANS_TO_DISSIPATING)


func turn_on_shield() -> void:
	_intends_to_shield = true
	check_conditions_to_shield()


func turn_off_shield() -> void:
	_intends_to_shield = false
	sc.send_event(TRANS_TO_DISSIPATING)


#=======================================================
# UTILITIES
#=======================================================
func expand_animation() -> void:
	match(control_node.charge_states.state):
		control_node.charge_states.State.NONE:
			control_node.anim_state.travel(EXPAND_LEVEL_0_TRANS_ANIM)
		control_node.charge_states.State.LEVEL1:
			control_node.anim_state.travel(EXPAND_LEVEL_1_TRANS_ANIM)
		control_node.charge_states.State.LEVEL2:
			control_node.anim_state.travel(EXPAND_LEVEL_2_TRANS_ANIM)
		control_node.charge_states.State.LEVEL3:
			control_node.anim_state.travel(EXPAND_LEVEL_3_TRANS_ANIM)


func dissipate_animation() -> void:
	match(control_node.charge_states.state):
		control_node.charge_states.State.NONE:
			control_node.anim_state.travel(DISSIPATE_LEVEL_0_TRANS_ANIM)
		control_node.charge_states.State.LEVEL1:
			control_node.anim_state.travel(DISSIPATE_LEVEL_1_TRANS_ANIM)
		control_node.charge_states.State.LEVEL2:
			control_node.anim_state.travel(DISSIPATE_LEVEL_2_TRANS_ANIM)
		control_node.charge_states.State.LEVEL3:
			control_node.anim_state.travel(DISSIPATE_LEVEL_3_TRANS_ANIM)
