class_name DroneFloatDistortionAnimation
extends Node

## Inject dependencies
@export var mesh: MeshInstance3D

## Animation Properties
@export_group("Off")
@export var distortion_mesh_intensity_off: float = 0.0

@export_group("On")
@export var distortion_mesh_intensity_on: float = 0.2

@export_group("Drone Open")
@export var float_distortion_open_pos_y: float = -1.25

@export_group("Drone Closed")
@export var float_distortion_closed_pos_y: float = -1.0

var material: ShaderMaterial
var material_next_pass: ShaderMaterial
var tw_noise_intensity_1: Tween
var tw_noise_intensity_2: Tween
var tw_position: Tween
var tw_flare: Tween

func _ready() -> void:
	material = mesh.get_surface_override_material(0)
	material_next_pass = material.next_pass


func _tween_noise_intensity(
	final_intensity: float,
	duration: float,
	trans: Tween.TransitionType,
	ease_type: Tween.EaseType
	) -> void:
		if tw_noise_intensity_1: tw_noise_intensity_1.kill()
		tw_noise_intensity_1 = create_tween()
		tw_noise_intensity_1.tween_property(material, "shader_parameter/noise_intensity", final_intensity, duration)\
			.set_trans(trans)\
			.set_ease(ease_type)
		
		if tw_noise_intensity_2: tw_noise_intensity_2.kill()
		tw_noise_intensity_2 = create_tween()
		tw_noise_intensity_1.tween_property(material_next_pass, "shader_parameter/noise_intensity", final_intensity, duration)\
			.set_trans(trans)\
			.set_ease(ease_type)
		
		await tw_noise_intensity_1.finished


func _tween_position(
	final_position: float,
	duration: float,
	trans: Tween.TransitionType,
	ease_type: Tween.EaseType
) -> void:
	if tw_position: tw_position.kill()
	tw_position = create_tween()
	tw_position.tween_property(mesh, "position", Vector3.UP * final_position, duration)\
		.set_trans(trans)\
		.set_ease(ease_type)
	
	await tw_position.finished

func _tween_flare(
	initial_value: float,
	final_value: float,
	duration: float,
	trans: Tween.TransitionType,
	ease_type: Tween.EaseType
) -> void:
	if tw_flare: tw_flare.kill()
	tw_flare = create_tween()
	tw_flare.tween_property(material_next_pass, "shader_parameter/flare_threshold", final_value, duration)\
		.set_trans(trans)\
		.set_ease(ease_type)\
		.from(initial_value)
	
	await tw_flare.finished


func turn_on(duration: float) -> void:
	material_next_pass.set_shader_parameter("flare_threshold", 1.0)
	await _tween_noise_intensity(distortion_mesh_intensity_on, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)


func turn_off(duration: float) -> void:
	material_next_pass.set_shader_parameter("flare_threshold", 1.0)
	await _tween_noise_intensity(distortion_mesh_intensity_off, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)


func drone_open_position() -> void:
	mesh.position.y = float_distortion_open_pos_y


func drone_closed_position() -> void:
	mesh.position.y = float_distortion_closed_pos_y


func drone_open(duration: float) -> void:
	_tween_position(float_distortion_open_pos_y, duration, Tween.TRANS_SPRING, Tween.EASE_OUT)


func drone_close(duration: float) -> void:
	_tween_position(float_distortion_closed_pos_y, duration, Tween.TRANS_SPRING, Tween.EASE_IN)


func drone_jump(duration: float) -> void:
	_tween_flare(0.2, 1.0, duration, Tween.TRANS_BACK, Tween.EASE_IN)
