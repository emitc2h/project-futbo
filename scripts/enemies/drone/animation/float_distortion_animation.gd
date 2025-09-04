class_name DroneFloatDistortionAnimation
extends Node

## Inject dependencies
@export var mesh: MeshInstance3D

## Animation Properties
@export_group("Off")
@export var distortion_mesh_intensity_off: float = 0.0
@export var distortion_off_duration: float = 0.5

@export_group("On")
@export var distortion_mesh_intensity_on: float = 1.0
@export var distortion_on_duration: float = 1.0

@export_group("Drone Open")
@export var float_distortion_open_pos_y: float = -1.06

@export_group("Drone Closed")
@export var float_distortion_closed_pos_y: float = -0.73

var material: ShaderMaterial
var tween: Tween

func _ready() -> void:
	material = mesh.get_surface_override_material(0)


func _tween(
	initial_intensity: float,
	final_intensity: float,
	duration: float,
	trans: Tween.TransitionType,
	ease: Tween.EaseType
	) -> void:
		if tween: tween.kill()
		tween = get_tree().create_tween()
		tween.tween_property(material, "shader_parameter/noise_intensity", final_intensity, duration)\
			.set_trans(trans)\
			.set_ease(ease)
		
		await tween.finished


func turn_on() -> void:
	await _tween(distortion_mesh_intensity_off, distortion_mesh_intensity_on, distortion_on_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)


func turn_off() -> void:
	await _tween(distortion_mesh_intensity_on, distortion_mesh_intensity_off, distortion_off_duration, Tween.TRANS_LINEAR, Tween.EASE_IN)


func drone_open_position() -> void:
	mesh.position.y = float_distortion_open_pos_y


func drone_closed_position() -> void:
	mesh.position.y = float_distortion_closed_pos_y
