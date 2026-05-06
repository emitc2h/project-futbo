@tool
class_name VisualArrow
extends Node3D

@export var arrow_mesh: MeshInstance3D
@export var scan_duration: float = 1.0
@export var pause_duration: float = 0.1
var material: ShaderMaterial

var tw_dissolve_in: Tween
var tw_dissolve_out: Tween


func _ready() -> void:
	material = arrow_mesh.get_surface_override_material(0)
	material.set_shader_parameter("dissolve_value_in", 0.0)
	material.set_shader_parameter("dissolve_value_out", 1.0)
	
	dissolve_in_pass()


func dissolve_in_pass() -> void:
	await get_tree().create_timer(pause_duration).timeout
	material.set_shader_parameter("dissolve_value_out", 1.0)
	tw_dissolve_in = create_tween()
	tw_dissolve_in.tween_property(material, "shader_parameter/dissolve_value_in", 1.0, scan_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(0.0)
	tw_dissolve_in.finished.connect(dissolve_out_pass)


func dissolve_out_pass() -> void:
	await get_tree().create_timer(pause_duration).timeout
	material.set_shader_parameter("dissolve_value_in", 1.0)
	tw_dissolve_out = create_tween()
	tw_dissolve_out.tween_property(material, "shader_parameter/dissolve_value_out", 0.0, scan_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(1.0)
	tw_dissolve_out.finished.connect(dissolve_in_pass)
