class_name DroneEnginesAnimation
extends Node

## Inject dependencies
@export var model: DroneModel

## Animation Properties
@onready var engines_off_props: DroneEnginesProps = $EnginesOffProps
@onready var engines_thrust_props: DroneEnginesProps = $EnginesThrustProps
@onready var engines_burst_props: DroneEnginesProps = $EnginesBurstProps

## Main Drone Model Mesh
var drone_mesh: MeshInstance3D

## Exhaust
var exhaust_material: ShaderMaterial

## Tweens
var exhaust1_tween: Tween
var exhaust2_tween: Tween

func _ready() -> void:
	## Retrieve meshes
	drone_mesh = model.get_node("Armature/Skeleton3D/drone")
	
	## Retrieve materials
	exhaust_material = drone_mesh.get_surface_override_material(6)
	
	## Initialize
	_apply_props(engines_off_props)


## Apply Properties
func _apply_props(props: DroneEnginesProps) -> void:
	exhaust_material.set_shader_parameter("noise_speed", props.exhaust_noise_speed)
	exhaust_material.set_shader_parameter("noise_intensity", props.exhaust_noise_intensity)


func _tween_engines(
	initial_props: DroneEnginesProps,
	final_props: DroneEnginesProps,
	duration: float,
	exhaust_ease: Tween.EaseType,
	exhaust_trans: Tween.TransitionType
	) -> void:
		
	## Initial state
	_apply_props(initial_props)

	if initial_props.exhaust_noise_speed != final_props.exhaust_noise_speed:
		if exhaust1_tween: exhaust1_tween.kill()
		exhaust1_tween = get_tree().create_tween()
		exhaust1_tween.tween_property(exhaust_material, "shader_parameter/noise_speed", final_props.exhaust_noise_speed, duration)\
			.set_ease(exhaust_ease)\
			.set_trans(exhaust_trans)
	
	if initial_props.exhaust_noise_intensity != final_props.exhaust_noise_intensity:
		if exhaust2_tween: exhaust2_tween.kill()
		exhaust2_tween = get_tree().create_tween()
		exhaust2_tween.tween_property(exhaust_material, "shader_parameter/noise_intensity", final_props.exhaust_noise_intensity, duration)\
			.set_ease(exhaust_ease)\
			.set_trans(exhaust_trans)
	
	await exhaust1_tween.finished
	return


func off_to_thrust(duration: float) -> void:
	await _tween_engines(engines_off_props, engines_thrust_props, duration, Tween.EASE_OUT, Tween.TRANS_BACK)
	return


func off_to_burst(duration: float) -> void:
	await _tween_engines(engines_off_props, engines_burst_props, duration, Tween.EASE_OUT, Tween.TRANS_BACK)
	return


func thrust_to_off(duration: float) -> void:
	await _tween_engines(engines_thrust_props, engines_off_props, duration, Tween.EASE_OUT, Tween.TRANS_QUART)
	return


func burst_to_off(duration: float) -> void:
	await _tween_engines(engines_burst_props, engines_off_props, duration, Tween.EASE_OUT, Tween.TRANS_QUART)
	return


func thrust_to_burst(duration: float) -> void:
	await _tween_engines(engines_thrust_props, engines_burst_props, duration, Tween.EASE_OUT, Tween.TRANS_LINEAR)
	return


func burst_to_thrust(duration: float) -> void:
	await _tween_engines(engines_burst_props, engines_thrust_props, duration, Tween.EASE_OUT, Tween.TRANS_LINEAR)
	return
