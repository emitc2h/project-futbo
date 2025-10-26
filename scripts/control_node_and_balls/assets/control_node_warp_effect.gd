class_name ControlNodeWarpEffect
extends Node3D

@onready var warp_mesh: MeshInstance3D = $WarpMesh
@onready var vfx_mesh: MeshInstance3D = $VFXMesh
@onready var light: OmniLight3D = $OmniLight3D

var warp_material: ShaderMaterial
var vfx_material: ShaderMaterial

signal open_warp_portal_finished
signal close_warp_portal_finished
signal dematerialized_finished
signal materialized_finished


func _ready() -> void:
	warp_material = warp_mesh.get_surface_override_material(0)
	vfx_material = vfx_mesh.get_surface_override_material(0)
	reset()


func reset() -> void:
	## Initiate warp material values
	warp_material.set_shader_parameter("power", 5.0)
	
	## Initiate VFX values
	vfx_material.set_shader_parameter("ring_emission_strength", 25.0)
	vfx_material.set_shader_parameter("ring_threshold", 0.0)
	vfx_material.set_shader_parameter("ring_rotation_speed", 0.0)
	
	vfx_material.set_shader_parameter("rays_emission_strength", 5.0)
	vfx_material.set_shader_parameter("rays_threshold", 0.0)
	
	vfx_material.set_shader_parameter("center_emission_strength", 5.0)
	vfx_material.set_shader_parameter("center_threshold", 0.0)
	vfx_material.set_shader_parameter("center_rotation_speed", 5.0)
	vfx_material.set_shader_parameter("center_scale", 0.1)
	
	## Initiate light values
	light.light_energy = 0.0
	
	warp_mesh.visible = false
	vfx_mesh.visible = false


func open_warp_portal(duration: float) -> void:
	warp_mesh.visible = true
	vfx_mesh.visible = true
	var tw_warp: Tween = create_tween()
	tw_warp.tween_property(warp_material, "shader_parameter/power", -0.6, duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.from(5.0)
	
	var tw_ring_threshold: Tween = create_tween()
	tw_ring_threshold.tween_property(vfx_material, "shader_parameter/ring_threshold", 1.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(0.0)
	
	var tw_ring_rotation: Tween = create_tween()
	tw_ring_rotation.tween_property(vfx_material, "shader_parameter/ring_rotation_speed", -18.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(0.0)
		
	var tw_light: Tween = create_tween()
	tw_light.tween_property(light, "light_energy", 1.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(0.0)
	
	await tw_ring_rotation.finished
	open_warp_portal_finished.emit()


func dematerialize(duration: float) -> void:
	var tw_rays_threshold: Tween = create_tween()
	tw_rays_threshold.tween_property(vfx_material, "shader_parameter/rays_threshold", 1.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(0.0)
	
	tw_rays_threshold.tween_property(vfx_material, "shader_parameter/rays_threshold", 0.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	var tw_rays_emission: Tween = create_tween()
	tw_rays_emission.tween_property(vfx_material, "shader_parameter/rays_emission_strength", 100.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(5.0)
	
	tw_rays_emission.tween_property(vfx_material, "shader_parameter/rays_emission_strength", 5.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	var tw_light: Tween = create_tween()
	tw_light.tween_property(light, "light_energy", 10.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(1.0)
	
	tw_light.tween_property(light, "light_energy", 0.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
		
	await tw_rays_emission.finished
	dematerialized_finished.emit()


func close_warp_portal(duration: float) -> void:
	var tw_ring_threshold: Tween = create_tween()
	tw_ring_threshold.tween_interval(duration / 2.0)
	tw_ring_threshold.tween_property(vfx_material, "shader_parameter/ring_threshold", 0.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(1.0)
	
	var tw_ring_rotation: Tween = create_tween()
	tw_ring_rotation.tween_interval(duration / 2.0)
	tw_ring_rotation.tween_property(vfx_material, "shader_parameter/ring_rotation_speed", 0.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(-18.0)
	
	var tw_warp: Tween = create_tween()
	tw_warp.tween_property(warp_material, "shader_parameter/power", 5.0, duration)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.from(-0.6)
	
	await tw_warp.finished
	warp_mesh.visible = false
	vfx_mesh.visible = false
	close_warp_portal_finished.emit()


func materialize(duration: float) -> void:
	var tw_center_threshold: Tween = create_tween()
	tw_center_threshold.tween_property(vfx_material, "shader_parameter/center_threshold", 1.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(0.0)
	
	tw_center_threshold.tween_property(vfx_material, "shader_parameter/center_threshold", 0.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	var tw_center_scale: Tween = create_tween()
	tw_center_scale.tween_property(vfx_material, "shader_parameter/center_scale", 4.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(0.1)
	
	tw_center_scale.tween_property(vfx_material, "shader_parameter/center_scale", 0.1, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	var tw_center_emission: Tween = create_tween()
	tw_center_emission.tween_property(vfx_material, "shader_parameter/center_emission_strength", 50.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(5.0)
	
	tw_center_emission.tween_property(vfx_material, "shader_parameter/center_emission_strength", 5.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	var tw_light: Tween = create_tween()
	tw_light.tween_property(light, "light_energy", 10.0, duration / 2.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(1.0)
	
	tw_light.tween_property(light, "light_energy", 0.0, duration / 2.0)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	
	await tw_center_emission.finished
	materialized_finished.emit()
