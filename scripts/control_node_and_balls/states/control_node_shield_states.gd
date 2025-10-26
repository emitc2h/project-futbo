class_name ControlNodeShieldStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var control_node: ControlNode
@export var asset: ControlNodeAsset
@export var sc: StateChart
@export var shield_collision: StaticBody3D

## States Enum
enum State {OFF = 0, CHARGING = 1, INFLATING = 2, ON = 3, DISSIPATING = 4}
var state: State = State.OFF

## State transition constants
const TRANS_TO_OFF: String = "Shield: to off"
const TRANS_TO_CHARGING: String = "Shield: to charging"
const TRANS_TO_INFLATING: String = "Shield: to inflating"
const TRANS_TO_ON: String = "Shield: to on"
const TRANS_TO_DISSIPATING: String = "Shield: to dissipating"

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
	
	asset.shield_anim.charge_shield_finished.connect(_on_charge_shield_finished)
	asset.shield_anim.inflate_shield_finished.connect(_on_inflate_shield_finished)
	asset.shield_anim.dissipate_shield_finished.connect(_on_dissipate_shield_finished)
	asset.shield_anim.blow_finished.connect(_on_blow_finished)
	
	## Disable the shield collision shape by default
	shield_collision.set_collision_layer_value(6, false)


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	
	## Re-enable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = true
	asset.shield_anim.animate_to_state(control_node.charge_states.state, state)


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	state = State.CHARGING
	
	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false
	
	asset.shield_anim.charge_shield(0.3)


# inflating state
#----------------------------------------
func _on_inflating_state_entered() -> void:
	state = State.INFLATING

	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false
	
	asset.shield_anim.inflate_shield(0.3)

# on state
#----------------------------------------
func _on_on_state_entered() -> void:
	state = State.ON
	
	shield_collision.set_collision_layer_value(6, true)
	asset.shield_anim.set_shield_anim_state_on()
	
	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false


func _on_on_state_exited() -> void:
	shield_collision.set_collision_layer_value(6, false)


# dissipating state
#----------------------------------------
func _on_dissipating_state_entered() -> void:
	state = State.DISSIPATING
	
	## Disable the spinning animation
	control_node.control_node_control_states.spins_during_dribble = false
	
	asset.shield_anim.dissipate_shield(0.3)


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_player_idle_entered() -> void:
	_player_is_idle = true
	check_conditions_to_shield()


func _on_player_idle_exited() -> void:
	_player_is_idle = false
	check_conditions_to_shield()
	sc.send_event(TRANS_TO_DISSIPATING)


func _on_player_dribbling_entered() -> void:
	_player_is_dribbling = true
	check_conditions_to_shield()


func _on_player_dribbling_exited() -> void:
	_player_is_dribbling = false
	check_conditions_to_shield()
	sc.send_event(TRANS_TO_DISSIPATING)


func _on_player_moved() -> void:
	sc.send_event(TRANS_TO_DISSIPATING)
	check_conditions_to_shield()


func _on_charge_shield_finished() -> void:
	sc.send_event(TRANS_TO_INFLATING)


func _on_inflate_shield_finished() -> void:
	sc.send_event(TRANS_TO_ON)


func _on_dissipate_shield_finished() -> void:
	sc.send_event(TRANS_TO_OFF)


func _on_blow_finished() -> void:
	control_node.control_node_control_states.spins_during_dribble = true

#=======================================================
# CONTROLS
#=======================================================
func check_conditions_to_shield() -> void:
	_shield_allowed = _player_is_idle and _player_is_dribbling and _intends_to_shield
	## If all conditions are met
	if _shield_allowed:
		sc.send_event(TRANS_TO_CHARGING)


func turn_on_shield() -> void:
	_intends_to_shield = true
	check_conditions_to_shield()


func turn_off_shield() -> void:
	_intends_to_shield = false
	sc.send_event(TRANS_TO_DISSIPATING)
