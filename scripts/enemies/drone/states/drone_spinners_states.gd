class_name DroneSpinnersStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var model: DroneModel

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


func _ready() -> void:
	model.anim_state_started.connect(_on_anim_state_started)
	model.anim_state_finished.connect(_on_anim_state_finished)
	var anim_tree: AnimationTree = model.get_node("AnimationTree")
	anim_state = anim_tree.get("parameters/playback")


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	Signals.debug_running_log.emit("OFF state entered")
	state = State.OFF


# charging state
#----------------------------------------
func _on_charging_state_entered() -> void:
	Signals.debug_running_log.emit("CHARGING state entered")
	state = State.CHARGING
	model.spinners_disengage_target()
	anim_state.travel("charge up")
	model.charge_spinners(2.7083)


# fire state
#----------------------------------------
func _on_fire_state_entered() -> void:
	Signals.debug_running_log.emit("FIRE state entered")
	state = State.FIRE
	model.spinners_engage_target()
	model.fire_spinners(0.7)


func _on_to_off_taken() -> void:
	fire_finished.emit()


# signal handling
#========================================
func _on_anim_state_started(anim_name: String) -> void:
	Signals.debug_running_log.emit("anim state started: " + anim_name)


func _on_anim_state_finished(anim_name: String) -> void:
	Signals.debug_running_log.emit("anim state finished: " + anim_name)
	if anim_name == "charge up":
		sc.send_event(TRANS_TO_FIRE)
	if anim_name == "fire":
		sc.send_event(TRANS_TO_OFF)
		model.spinners_disengage_target()
