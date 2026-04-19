class_name DroneSpinnersStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var asset: DroneAsset

## States Enum
enum State {OFF = 0, CHARGING = 1, FIRE = 2}
var state: State = State.OFF

## State transition constants
const TRANS_TO_CHARGING: String = "Spinners: to charging"
const TRANS_TO_FIRE: String = "Spinners: to fire"
const TRANS_TO_OFF: String = "Spinners: to off"

## Drone nodes controlled by this state
var anim_state: AnimationNodeStateMachinePlayback

## Signals
signal fire_finished

## Parameters
var num_bolts: int = 1


func _ready() -> void:
	asset.anim_state_finished.connect(_on_anim_state_finished)
	var anim_tree: AnimationTree = asset.get_node("AnimationTree")
	anim_state = anim_tree.get("parameters/playback")


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	state = State.CHARGING
	asset.spinners_disengage_target()
	anim_state.travel("charge up")
	asset.charge_spinners(2.7083)


# fire state
#----------------------------------------
func _on_fire_state_entered() -> void:
	state = State.FIRE
	asset.spinners_engage_target()
	asset.fire_spinners(0.7)


func _on_fire_state_exited() -> void:
	pass


##########################################
## SIGNALS                              ##
##########################################
func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "charge up":
		sc.send_event(TRANS_TO_FIRE)
	if anim_name == "fire":
		num_bolts -= 1
		## Continue firing if more bolts should be fired
		if num_bolts > 0:
			anim_state.travel("fire")
			sc.send_event(TRANS_TO_FIRE)
		else:
			## Reset num_bolts to default
			num_bolts = 1
			fire_finished.emit()
			sc.send_event(TRANS_TO_OFF)
			asset.spinners_disengage_target()
