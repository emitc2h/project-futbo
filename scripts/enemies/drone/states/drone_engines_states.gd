class_name DroneEnginesStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart

## Parameters
@export_group("Exhaust Parameters")
@export var off_noise_intensity: float = 0.0
@export var off_noise_speed: float = 0.0
@export var thrust_noise_intensity: float = 15.0
@export var thrust_noise_speed: float = 2.0
@export var burst_noise_intensity: float = 100.0
@export var burst_noise_speed: float = 3.0

@export_group("Movement Speed")
@export var off_speed: float = 3.0
@export var thrust_speed: float = 5.0
@export var burst_speed: float = 12.0

## States Enum
enum State {OFF = 0, THRUST = 1, BURST = 2, STOPPING = 3}
var state: State = State.OFF

## State transition constants
const TRANS_OFF_TO_THRUST: String = "Engines: off to thrust"
const TRANS_OFF_TO_BURST: String = "Engines: off to burst"

const TRANS_THRUST_TO_STOPPING: String = "Engines: thrust to stopping"
const TRANS_THRUST_TO_QUICK_OFF: String = "Engines: thrust to quick off"
const TRANS_THRUST_TO_BURST: String = "Engines: thrust to burst"

const TRANS_BURST_TO_STOPPING: String = "Engines: burst to stopping"
const TRANS_BURST_TO_QUICK_OFF: String = "Engines: burst to quick off"
const TRANS_BURST_TO_THRUST: String = "Engines: burst to thrust"

const TRANS_STOPPING_TO_OFF: String = "Engines: stopping to off"

## Drone nodes controlled by this state
@onready var model_mesh: Node3D = drone.get_node("TrackTransformContainer/DroneModel/Armature/Skeleton3D/drone")
@onready var exhaust_material: ShaderMaterial = model_mesh.get_surface_override_material(6)

@onready var model: DroneModel = drone.get_node("TrackTransformContainer/DroneModel")
@onready var model_anim_tree: AnimationTree = drone.get_node("TrackTransformContainer/DroneModel/AnimationTree")
@onready var anim_state: AnimationNodeStateMachinePlayback

## Internal variables
var engine_tween: Tween

## Signals
signal engines_are_off

## Utils
func _tween_engines(
	noise_speed: float,
	noise_intensity_from: float,
	noise_intensity_to: float,
	ease: Tween.EaseType,
	trans: Tween.TransitionType,
	duration: float) -> Tween:
		exhaust_material.set_shader_parameter("noise_speed", noise_speed)
		## Interrupt any ongoing tween so animations don't conflict
		if engine_tween:
			engine_tween.kill()
		
		engine_tween = get_tree().create_tween()
		engine_tween.tween_property(
			exhaust_material,
			"shader_parameter/noise_intensity",
			noise_intensity_to,
			duration)\
			.set_ease(ease)\
			.set_trans(trans)\
			.from(noise_intensity_from)
		return engine_tween


func _ready() -> void:
	anim_state = model_anim_tree.get("parameters/playback")
	model.anim_state_finished.connect(_on_anim_state_finished)


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	engines_are_off.emit()


func _on_off_to_thrust_taken() -> void:
	_tween_engines(
		thrust_noise_speed,
		off_noise_intensity, thrust_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_BACK,
		0.6)
	anim_state.travel("start thrust")


func _on_off_to_burst_taken() -> void:
	_tween_engines(
		burst_noise_speed,
		off_noise_intensity, burst_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_BACK,
		0.4)
	anim_state.travel("start thrust")


# thrust state
#----------------------------------------
func _on_thrust_state_entered() -> void:
	state = State.THRUST


func _on_thrust_to_stopping_taken() -> void:
	_tween_engines(
		off_noise_speed,
		thrust_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.8)
	anim_state.travel("stop thrust")


func _on_thrust_to_quick_off_taken() -> void:
	_tween_engines(
		off_noise_speed,
		thrust_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.15)


func _on_thrust_to_burst_taken() -> void:
	_tween_engines(
		burst_noise_speed,
		thrust_noise_intensity, burst_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_LINEAR,
		0.6)


# burst state
#----------------------------------------
func _on_burst_state_entered() -> void:
	state = State.BURST


func _on_burst_to_stopping_taken() -> void:
	_tween_engines(
		off_noise_speed,
		burst_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.8)
	anim_state.travel("stop thrust")


func _on_burst_to_quick_off_taken() -> void:
	_tween_engines(
		off_noise_speed,
		burst_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.15)


func _on_burst_to_thrust_taken() -> void:
	_tween_engines(
		thrust_noise_speed,
		burst_noise_intensity, thrust_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_LINEAR,
		0.6)


# stopping state
#----------------------------------------
func _on_stopping_state_entered() -> void:
	state = State.STOPPING


func _on_anim_state_finished(anim_name: String) -> void:
	if anim_name == "stop thrust":
		sc.send_event(TRANS_STOPPING_TO_OFF)
