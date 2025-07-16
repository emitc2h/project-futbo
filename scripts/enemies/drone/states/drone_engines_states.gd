class_name DroneEnginesStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: DroneV2
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
enum State {OFF = 0, THRUST = 1, BURST = 2}
var state: State = State.OFF

## State transition constants

## Drone nodes controlled by this state
@onready var model_mesh: Node3D = drone.get_node("TrackTransformContainer/DroneModel/Armature/Skeleton3D/drone")
@onready var exhaust_material: ShaderMaterial = model_mesh.get_surface_override_material(6)

@onready var model_anim_tree: AnimationTree = drone.get_node("TrackTransformContainer/DroneModel/AnimationTree")
@onready var anim_state: AnimationNodeStateMachinePlayback


## Utils
func _tween_engines(
	noise_speed: float,
	noise_intensity_from: float,
	noise_intensity_to: float,
	ease: Tween.EaseType,
	trans: Tween.TransitionType,
	duration: float) -> Tween:
		exhaust_material.set_shader_parameter("noise_speed", noise_speed)
		
		var tween: Tween = get_tree().create_tween()
		tween.tween_property(
			exhaust_material,
			"shader_parameter/noise_intensity",
			noise_intensity_to,
			duration)\
			.set_ease(ease)\
			.set_trans(trans)\
			.from(noise_intensity_from)
		return tween


func _ready() -> void:
	anim_state = model_anim_tree.get("parameters/playback")


# off state
#----------------------------------------
func _on_off_state_entered() -> void:
	state = State.OFF
	drone.physics_mode_states.speed = off_speed
	anim_state.travel("idle")


func _on_off_to_thrust_taken() -> void:
	_tween_engines(
		thrust_noise_speed,
		off_noise_intensity, thrust_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_BACK,
		0.6)


func _on_off_to_burst_taken() -> void:
	_tween_engines(
		burst_noise_speed,
		off_noise_intensity, burst_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_BACK,
		0.4)


# thrust state
#----------------------------------------
func _on_thrust_state_entered() -> void:
	state = State.THRUST
	drone.physics_mode_states.speed = thrust_speed
	anim_state.travel("idle thrust")


func _on_thrust_to_off_taken() -> void:
	_tween_engines(
		off_noise_speed,
		thrust_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.8)


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
	drone.physics_mode_states.speed = burst_speed
	anim_state.travel("idle thrust")


func _on_burst_to_off_taken() -> void:
	_tween_engines(
		off_noise_speed,
		burst_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.8)


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
