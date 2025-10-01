class_name CharacterDamageStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

## States Enum
enum State {ABLE = 0, KNOCKED = 1, OUT = 2, RECOVERING = 3, DOWN = 4}
var state: State = State.ABLE

## State transition constants
const TRANS_TO_ABLE: String = "Damage: to able"
const TRANS_TO_KNOCKED: String = "Damage: to knocked"
const TRANS_TO_OUT: String = "Damage: to out"
const TRANS_TO_RECOVERING: String = "Damage: to recovering"
const TRANS_TO_DOWN: String = "Damage: to down"

# able state
#----------------------------------------
func _on_able_state_entered() -> void:
	state = State.ABLE


# knocked state
#----------------------------------------
func _on_knocked_state_entered() -> void:
	state = State.KNOCKED


# knocked state
#----------------------------------------
func _on_out_state_entered() -> void:
	state = State.OUT


# recovering state
#----------------------------------------
func _on_recovering_state_entered() -> void:
	state = State.RECOVERING


# down state
#----------------------------------------
func _on_down_state_entered() -> void:
	state = State.DOWN
