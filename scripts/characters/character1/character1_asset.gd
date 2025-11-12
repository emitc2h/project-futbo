class_name Character1Asset
extends CharacterAssetBase

@onready var model: MeshInstance3D = $CharacterAsset/Armature/Skeleton3D/CharacterSkinned
var shield_material: ShaderMaterial
var jump_distortion_material: ShaderMaterial
var jump_flare_material: ShaderMaterial

var tw_jump_intensity: Tween
var tw_jump_stretch: Tween
var tw_jump_flare_threshold: Tween


func _ready() -> void:
	super._ready()
	shield_material = model.get_surface_override_material(4)
	jump_distortion_material = model.get_surface_override_material(5)
	jump_flare_material = jump_distortion_material.next_pass
	
	shield_material.set_shader_parameter("dissolve_value", 1.0)
	
	jump_distortion_material.set_shader_parameter("noise_intensity", 0.0)
	jump_distortion_material.set_shader_parameter("stretch", 0.01)
	jump_distortion_material.set_shader_parameter("enabled", false)
	
	jump_flare_material.set_shader_parameter("noise_intensity", 0.0)
	jump_flare_material.set_shader_parameter("stretch", 0.01)
	jump_flare_material.set_shader_parameter("enabled", false)


func jump(duration: float = 1.0) -> void:
	super.jump()
	jump_distortion_material.set_shader_parameter("enabled", true)
	jump_flare_material.set_shader_parameter("enabled", true)
	
	if tw_jump_intensity: tw_jump_intensity.kill()
	tw_jump_intensity = create_tween()
	tw_jump_intensity.parallel().tween_property(jump_distortion_material, "shader_parameter/noise_intensity", 0.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)\
		.from(1.0)
	
	tw_jump_intensity.parallel().tween_property(jump_flare_material, "shader_parameter/noise_intensity", 0.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)\
		.from(1.0)
	
	if tw_jump_stretch: tw_jump_stretch.kill()
	tw_jump_stretch = create_tween()
	tw_jump_stretch.parallel().tween_property(jump_distortion_material, "shader_parameter/stretch", 0.5, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)\
		.from(0.01)
	
	tw_jump_stretch.parallel().tween_property(jump_flare_material, "shader_parameter/stretch", 0.5, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)\
		.from(0.01)
	
	if tw_jump_flare_threshold: tw_jump_flare_threshold.kill()
	tw_jump_flare_threshold = create_tween()
	tw_jump_flare_threshold.tween_property(jump_flare_material, "shader_parameter/flare_threshold", 1.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_EXPO)\
		.from(0.8)
		
	await tw_jump_stretch.finished
	jump_distortion_material.set_shader_parameter("enabled", false)
	jump_flare_material.set_shader_parameter("enabled", false)
		
