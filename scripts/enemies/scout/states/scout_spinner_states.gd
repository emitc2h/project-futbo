class_name ScoutSpinnerStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart

## States Enum
enum State {OFF = 0, CHARGING = 1, FIRE = 2}
var state: State = State.OFF

## State transition constants
const TRANS_TO_CHARGING: String = "Spinner: to charging"
const TRANS_TO_FIRE: String = "Spinner: to fire"
const TRANS_TO_OFF: String = "Spinner: to off"

## Signals
signal fire_finished


func _ready() -> void:
	scout.asset.anim_state_finished.connect(_on_anim_state_finished)


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	state = State.CHARGING
	scout.anim_state.travel("charge")
	scout.asset.charge_spinners(2.7083)


# fire state
#----------------------------------------
func _on_fire_state_entered() -> void:
	state = State.FIRE
	scout.asset.fire_spinners(0.7)


##########################################
## SIGNALS                              ##
##########################################
func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "charge":
		sc.send_event(TRANS_TO_FIRE)
	if anim_name == "fire":
		fire_finished.emit()
		sc.send_event(TRANS_TO_OFF)
