class_name DroneEnginesStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var model: DroneModel

## Parameters
@export_group("Exhaust Parameters")
@export var off_noise_intensity: float = 0.0
@export var off_noise_speed: float = 0.0
@export var thrust_noise_intensity: float = 15.0
@export var thrust_noise_speed: float = 2.0
@export var burst_noise_intensity: float = 100.0
@export var burst_noise_speed: float = 3.0

@export_group("Movement Speed")
@export var off_speed: float = 4.0
@export var thrust_speed: float = 7.0
@export var burst_speed: float = 12.0

## States Enum
enum State {OFF = 0, THRUST = 1, BURST = 2, STOPPING = 3}
var state: State = State.OFF

## State transition constants
const TRANS_TO_THRUST: String = "Engines: to thrust"
const TRANS_TO_BURST: String = "Engines: to burst"
const TRANS_TO_STOPPING: String = "Engines: to stopping"
const TRANS_TO_QUICK_OFF: String = "Engines: to quick off"
const TRANS_TO_OFF: String = "Engines: to off"


## Signals
signal engines_are_off


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	engines_are_off.emit()


func _on_off_to_thrust_taken() -> void:
	model.engines_animation.off_to_thrust(0.6)


func _on_off_to_burst_taken() -> void:
	model.engines_animation.off_to_burst(0.4)


# thrust state
#----------------------------------------
func _on_thrust_state_entered() -> void:
	state = State.THRUST


func _on_thrust_to_stopping_taken() -> void:
	await model.engines_animation.thrust_to_off(0.8)
	sc.send_event(TRANS_TO_OFF)


func _on_thrust_to_quick_off_taken() -> void:
	model.engines_animation.thrust_to_off(0.15)


func _on_thrust_to_burst_taken() -> void:
	model.engines_animation.thrust_to_burst(0.4)


# burst state
#----------------------------------------
func _on_burst_state_entered() -> void:
	state = State.BURST


func _on_burst_to_stopping_taken() -> void:
	await model.engines_animation.burst_to_off(0.8)
	sc.send_event(TRANS_TO_OFF)


func _on_burst_to_quick_off_taken() -> void:
	model.engines_animation.burst_to_off(0.15)


func _on_burst_to_thrust_taken() -> void:
	model.engines_animation.burst_to_thrust(0.6)


# stopping state
#----------------------------------------
func _on_stopping_state_entered() -> void:
	state = State.STOPPING
