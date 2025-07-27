class_name DroneClosedShieldModel
extends Node3D

## Get a handle on the shader material
@onready var material: ShaderMaterial = $ClosedShield.get_surface_override_material(0)

func hit() -> void:
	material.set_shader_parameter("dissolve_value_in", 0.0)
	material.set_shader_parameter("dissolve_value_out", 1.0)
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	tween1.tween_property(material, "shader_parameter/dissolve_value_in", 1.0, 0.8)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)\
		.from(0.0)
	tween2.tween_property(material, "shader_parameter/dissolve_value_out", 0.0, 1.2)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)\
		.from(1.0)
	tween3.tween_property(material, "shader_parameter/emission_energy", 10.0, 1.2)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(60.0)
