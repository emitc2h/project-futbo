class_name EnginesAnimation
extends Node

## Inject dependencies
@export var mesh: MeshInstance3D
@export var engines_material_index: int

## Animation Properties
@onready var engines_off_props: EnginesProps = $EnginesOffProps
@onready var engines_thrust_props: EnginesProps = $EnginesThrustProps
@onready var engines_burst_props: EnginesProps = $EnginesBurstProps


## Exhaust
var exhaust_material: ShaderMaterial

## Tweens
var exhaust1_tween: Tween
var exhaust2_tween: Tween

func _ready() -> void:
	## Retrieve materials
	exhaust_material = mesh.get_surface_override_material(engines_material_index)
	
	## Initialize
	_apply_props(engines_off_props)


## Apply Properties
func _apply_props(props: EnginesProps) -> void:
	exhaust_material.set_shader_parameter("noise_speed", props.exhaust_noise_speed)
	exhaust_material.set_shader_parameter("noise_intensity", props.exhaust_noise_intensity)


func _tween_engines(
	initial_props: EnginesProps,
	final_props: EnginesProps,
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
