class_name ControlNodeShieldAnimation
extends Node

@export_group("Dependency Injection")
@export var asset: ControlNodeAsset
@export var light: OmniLight3D
@export var model: Node3D
@export var aura_mesh: MeshInstance3D

var shield_mesh: MeshInstance3D
var shield_material: ShaderMaterial
var shield_distortion_mesh: MeshInstance3D
var shield_distortion_material: ShaderMaterial
var aura_material: StandardMaterial3D
var lightning_particles: GPUParticles3D
var lightning_material: ShaderMaterial

enum Charge {NONE = 0, LEVEL_1 = 1, LEVEL_2 = 2, LEVEL_3 = 3, OFF = 4}
var charge: Charge = Charge.NONE

enum Shield {OFF = 0, ON = 1}
var shield: Shield = Shield.OFF

## A property can only be in one group of props
@export_group("Charge-only Props")
@export_subgroup("light")
@export var light_color: Dictionary[Charge, Color]
@export var light_energy: Dictionary[Charge, float]
@export_subgroup("shield")
@export var shield_modulate_factor: Dictionary[Charge, float]
@export var shield_dissolve_value: Dictionary[Charge, float]
@export_subgroup("lightning")
@export var lightning_window_size: Dictionary[Charge, float]
@export var lightning_amount_ratio: Dictionary[Charge, float]
@export var lightning_emission_factor: Dictionary[Charge, float]
@export var lightning_reverse: Dictionary[Charge, bool]
@export_subgroup("aura")
@export var aura_color: Dictionary[Charge, Color]

@export_group("Shield-only props")
@export_subgroup("shield")
@export var shield_scale: Dictionary[Shield, float]
@export var shield_alpha: Dictionary[Shield, float]
@export var shield_distortion: Dictionary[Shield, float]

@export_group("Charge & Shield props")
@export_subgroup("shield")
@export var shield_ripple_strength: Dictionary[Charge, Dictionary] = {
	Charge.NONE: { Shield.OFF: 0.02, Shield.ON: 0.01},
	Charge.LEVEL_1: { Shield.OFF: 0.03, Shield.ON: 0.01},
	Charge.LEVEL_2: { Shield.OFF: 0.06, Shield.ON: 0.02},
	Charge.LEVEL_3: { Shield.OFF: 0.1, Shield.ON: 0.03},
	Charge.OFF: { Shield.OFF: 0.02, Shield.ON: 0.01},
}
@export var shield_emission_energy: Dictionary[Charge, Dictionary] = {
	Charge.NONE: { Shield.OFF: 20.0, Shield.ON: 20.0},
	Charge.LEVEL_1: { Shield.OFF: 40.0, Shield.ON: 30.0},
	Charge.LEVEL_2: { Shield.OFF: 60.0, Shield.ON: 40.0},
	Charge.LEVEL_3: { Shield.OFF: 100.0, Shield.ON: 50.0},
	Charge.OFF: { Shield.OFF: 20.0, Shield.ON: 20.0},
}
@export var aura_scale: Dictionary[Charge, Dictionary] = {
	Charge.NONE: { Shield.OFF: 0.7, Shield.ON: 8.0},
	Charge.LEVEL_1: { Shield.OFF: 0.7, Shield.ON: 9.0},
	Charge.LEVEL_2: { Shield.OFF: 0.9, Shield.ON: 10.0},
	Charge.LEVEL_3: { Shield.OFF: 1.2, Shield.ON: 11.0},
	Charge.OFF: { Shield.OFF: 0.7, Shield.ON: 1.0},
}

## Tweens
var tw_light_color: Tween
var tw_light_energy: Tween
var tw_shield_modulate_factor: Tween
var tw_shield_scale: Tween
var tw_shield_distortion_scale: Tween
var tw_shield_alpha: Tween
var tw_shield_distortion: Tween
var tw_shield_ripple_strength: Tween
var tw_shield_emission_energy: Tween
var tw_shield_dissolve_value: Tween
# I don't want to be tweening lightning parameters, they reset the particle system except for amount ratio
# but tweening it doesn't really have a visible effect
var tw_aura_color: Tween
var tw_aura_scale: Tween

## Signals
signal charge_shield_finished
signal inflate_shield_finished
signal dissipate_shield_finished
signal blow_finished

## State trackers
var powering_up: bool= false
var powering_down: bool = false


func _ready() -> void:
	shield_mesh = model.get_node("ShieldMesh")
	shield_material = shield_mesh.get_surface_override_material(0)
	
	shield_distortion_mesh = model.get_node("DistortionShieldMesh")
	shield_distortion_material = shield_distortion_mesh.get_surface_override_material(0)
	
	aura_material = aura_mesh.get_surface_override_material(0)
	lightning_particles = asset.lightning_particles
	lightning_material = lightning_particles.draw_pass_1.surface_get_material(0)


##========================================##
## TWEENERS                              ##
##========================================##
func _tween_charge_only(final_charge: Charge, duration: float) -> void:
	if tw_light_color: tw_light_color.kill()
	tw_light_color = create_tween()
	tw_light_color.tween_property(light, "light_color", light_color[final_charge], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	if tw_light_energy: tw_light_energy.kill()
	tw_light_energy = create_tween()
	tw_light_energy.tween_property(light, "light_energy", light_energy[final_charge], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	if tw_shield_modulate_factor: tw_shield_modulate_factor.kill()
	tw_shield_modulate_factor = create_tween()
	tw_shield_modulate_factor.tween_property(shield_material, "shader_parameter/modulate_factor", shield_modulate_factor[final_charge], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	if tw_shield_dissolve_value: tw_shield_dissolve_value.kill()
	tw_shield_dissolve_value = create_tween()
	tw_shield_dissolve_value.tween_property(shield_material, "shader_parameter/dissolve_value", shield_dissolve_value[final_charge], duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		
	if tw_aura_color: tw_aura_color.kill()
	tw_aura_color = create_tween()
	tw_aura_color.tween_property(aura_material, "albedo_color", aura_color[final_charge], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	await tw_aura_color.finished
		
	## Setting particle shader parameters reset the particle emission, so do not tween
	lightning_material.set_shader_parameter("lightning_window_size", lightning_window_size[final_charge])
	lightning_particles.set("amount_ratio", lightning_amount_ratio[final_charge])
	lightning_material.set_shader_parameter("lightning_emission_factor", lightning_emission_factor[final_charge])
	lightning_material.set_shader_parameter("lightning_reverse", lightning_reverse[final_charge])
	
	charge = final_charge
	
	return


func _tween_shield_only(final_shield: Shield, duration: float) -> void:
	if tw_shield_scale: tw_shield_scale.kill()
	tw_shield_scale = create_tween()
	tw_shield_scale.tween_property(shield_mesh, "scale", Vector3.ONE * shield_scale[final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
	
	if tw_shield_distortion_scale: tw_shield_distortion_scale.kill()
	tw_shield_distortion_scale = create_tween()
	tw_shield_distortion_scale.tween_property(shield_distortion_mesh, "scale", Vector3.ONE * shield_scale[final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
	
	if tw_shield_alpha: tw_shield_alpha.kill()
	tw_shield_alpha = create_tween()
	tw_shield_alpha.tween_property(shield_material, "shader_parameter/alpha", shield_alpha[final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
	
	if tw_shield_distortion: tw_shield_distortion.kill()
	tw_shield_distortion = create_tween()
	tw_shield_distortion.tween_property(shield_distortion_material, "shader_parameter/noise_intensity", shield_distortion[final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	await tw_shield_scale.finished
	
	shield = final_shield
	return


func _tween_charge_and_shield(final_charge: Charge, final_shield: Shield, duration: float, blow_factor: float) -> void:
	if tw_shield_ripple_strength: tw_shield_ripple_strength.kill()
	tw_shield_ripple_strength = create_tween()
	tw_shield_ripple_strength.tween_property(shield_material, "shader_parameter/ripple_strength", shield_ripple_strength[final_charge][final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(shield_ripple_strength[charge][shield] * blow_factor)

	if tw_shield_emission_energy: tw_shield_emission_energy.kill()
	tw_shield_emission_energy = create_tween()
	tw_shield_emission_energy.tween_property(shield_material, "shader_parameter/emission_energy", shield_emission_energy[final_charge][final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(shield_emission_energy[charge][shield] * blow_factor)
	
	if tw_aura_scale: tw_aura_scale.kill()
	tw_aura_scale = create_tween()
	tw_aura_scale.tween_property(aura_mesh, "scale", Vector3.ONE * aura_scale[final_charge][final_shield], duration)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
	
	await tw_shield_ripple_strength.finished
	
	charge = final_charge
	shield = final_shield
	return


##========================================##
## APPLIERS                              ##
##========================================##
func _apply_charge_only(final_charge: Charge) -> void:
	light.light_color = light_color[final_charge]
	light.light_energy = light_energy[final_charge]
	shield_material.set_shader_parameter("modulate_factor", shield_modulate_factor[final_charge])
	shield_material.set_shader_parameter("dissolve_value", shield_dissolve_value[final_charge])
	aura_material.albedo_color = aura_color[final_charge]
	lightning_material.set_shader_parameter("lightning_window_size", lightning_window_size[final_charge])
	lightning_particles.set("amount_ratio", lightning_amount_ratio[final_charge])
	lightning_material.set_shader_parameter("lightning_emission_factor", lightning_emission_factor[final_charge])
	lightning_material.set_shader_parameter("lightning_reverse", lightning_reverse[final_charge])
	charge = final_charge


func _apply_shield_only(final_shield: Shield) -> void:
	shield_mesh.scale = Vector3.ONE * shield_scale[final_shield]
	shield_material.set_shader_parameter("alpha", shield_alpha[final_shield])
	shield = final_shield


func _apply_charge_and_shield(final_charge: Charge, final_shield: Shield) -> void:
	shield_material.set_shader_parameter("ripple_strength", shield_ripple_strength[final_charge][final_shield])
	shield_material.set_shader_parameter("emission_energy", shield_emission_energy[final_charge][final_shield])
	aura_mesh.scale = Vector3.ONE * aura_scale[final_charge][final_shield]
	charge = final_charge
	shield = final_shield
	


##========================================##
## UTILS                                 ##
##========================================##
func convert_charge_state(charge_state: ControlNodeChargeStates.State) -> Charge:
	return Charge.values()[charge_state]


func convert_shield_state(shield_state: ControlNodeShieldStates.State) -> Shield:
	match shield_state:
		ControlNodeShieldStates.State.OFF:
			return Shield.values()[0]
		ControlNodeShieldStates.State.ON:
			return Shield.values()[1]
		_:
			return Shield.values()[shield]


##========================================##
## CONTROLS                              ##
##========================================##
func animate_to_state(charge_state: ControlNodeChargeStates.State, shield_state: ControlNodeShieldStates.State, duration: float = 0.5, blow_factor: float = 1.0) -> void:
	var final_charge: Charge = convert_charge_state(charge_state)
	var final_shield: Shield = convert_shield_state(shield_state)
	_tween_charge_only(final_charge, duration)
	_tween_shield_only(final_shield, duration)
	_tween_charge_and_shield(final_charge, final_shield, duration, blow_factor)


func bounce(bounce_strength: float) -> void:
	## No bounce animation while powering up or down, so bounce can't cancel those animations
	if powering_up or powering_down:
		return
	
	if tw_shield_emission_energy: tw_shield_emission_energy.kill()
	tw_shield_emission_energy = create_tween()
	tw_shield_emission_energy.tween_property(shield_material, "shader_parameter/emission_energy", shield_emission_energy[charge][shield], 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(shield_emission_energy[charge][shield] * 25.0 * bounce_strength)

	if tw_shield_ripple_strength: tw_shield_ripple_strength.kill()
	tw_shield_ripple_strength = create_tween()
	tw_shield_ripple_strength.tween_property(shield_material, "shader_parameter/ripple_strength", shield_ripple_strength[charge][shield], 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(shield_ripple_strength[charge][shield] * 5.0 * bounce_strength)

	if tw_light_energy: tw_light_energy.kill()
	tw_light_energy = create_tween()
	tw_light_energy.tween_property(light, "light_energy", light_energy[charge], 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(light_energy[charge] * 2.0 * bounce_strength)


func charge_shield(duration: float = 0.5) -> void:
	if tw_shield_emission_energy: tw_shield_emission_energy.kill()
	tw_shield_emission_energy = create_tween()
	tw_shield_emission_energy.tween_property(shield_material, "shader_parameter/emission_energy", shield_emission_energy[charge][shield] * 10.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(shield_emission_energy[charge][shield])
	
	tw_shield_emission_energy.tween_property(shield_material, "shader_parameter/emission_energy", shield_emission_energy[charge][shield], 0.1 * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)
	

	if tw_shield_ripple_strength: tw_shield_ripple_strength.kill()
	tw_shield_ripple_strength = create_tween()
	tw_shield_ripple_strength.tween_property(shield_material, "shader_parameter/ripple_strength", shield_ripple_strength[charge][shield] * 10.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(shield_ripple_strength[charge][shield])
	
	tw_shield_ripple_strength.tween_property(shield_material, "shader_parameter/ripple_strength", shield_ripple_strength[charge][shield], 0.1 * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
	
	await tw_shield_emission_energy.finished
	charge_shield_finished.emit()


func inflate_shield(duration: float = 0.3) -> void:
	_tween_shield_only(Shield.ON, duration)
	await _tween_charge_and_shield(charge, Shield.ON, duration, 1.0)
	inflate_shield_finished.emit()
	return


func dissipate_shield(duration: float = 0.2) -> void:
	## Dissolve the shield
	if tw_shield_dissolve_value: tw_shield_dissolve_value.kill()
	tw_shield_dissolve_value = create_tween()
	tw_shield_dissolve_value.tween_property(shield_material, "shader_parameter/dissolve_value", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(1.0)
	
	if tw_aura_color: tw_aura_color.kill()
	tw_aura_color = create_tween()
	tw_aura_color.tween_property(aura_material, "albedo_color", Color.TRANSPARENT, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	await tw_shield_dissolve_value.finished
	
	## Make the shield reappear around the control node real quick
	_tween_charge_and_shield(charge, Shield.OFF, 0.1 * duration, 1.0)
	await _tween_shield_only(Shield.OFF, 0.1 * duration)
	
	tw_shield_dissolve_value = create_tween()
	tw_shield_dissolve_value.tween_property(shield_material, "shader_parameter/dissolve_value", 1.0, 0.1 * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)\
		.from(0.0)
		
	await tw_shield_dissolve_value.finished
	dissipate_shield_finished.emit()
	_apply_charge_only(Charge.NONE)
	_apply_shield_only(Shield.OFF)
	_apply_charge_and_shield(Charge.NONE, Shield.OFF)
	return


func blow(duration: float = 0.15) -> void:
	if tw_shield_scale: tw_shield_scale.kill()
	tw_shield_scale = create_tween()
	tw_shield_scale.tween_property(shield_mesh, "scale", Vector3.ONE * shield_scale[shield] * 1.3, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(Vector3.ONE * shield_scale[shield])
	
	if tw_shield_dissolve_value: tw_shield_dissolve_value.kill()
	tw_shield_dissolve_value = create_tween()
	tw_shield_dissolve_value.tween_property(shield_material, "shader_parameter/dissolve_value", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(1.0)
	
	if tw_shield_distortion: tw_shield_distortion.kill()
	tw_shield_distortion = create_tween()
	tw_shield_distortion.tween_property(shield_distortion_material, "shader_parameter/noise_intensity", shield_distortion[Shield.OFF], duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	if tw_aura_color: tw_aura_color.kill()
	tw_aura_color = create_tween()
	tw_aura_color.tween_property(aura_material, "albedo_color", Color.TRANSPARENT, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
	
	if tw_shield_emission_energy: tw_shield_emission_energy.kill()
	tw_shield_emission_energy = create_tween()
	tw_shield_emission_energy.tween_property(shield_material, "shader_parameter/emission_energy", shield_emission_energy[charge][shield], duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(shield_emission_energy[charge][shield] * 10.0)
	
	await tw_shield_emission_energy.finished
	blow_finished.emit()
	_apply_charge_only(Charge.OFF)
	_apply_shield_only(Shield.OFF)
	_apply_charge_and_shield(Charge.OFF, Shield.OFF)
	return
	

func set_shield_anim_state_on() -> void:
	shield = Shield.ON


func set_shield_anim_state_off() -> void:
	shield = Shield.OFF


func turn_off_lightning() -> void:
	lightning_particles.set("amount_ratio", 0.0)


func power_on(duration: float = 1.0) -> void:
	powering_up = true
	_tween_shield_only(Shield.OFF, duration)
	_tween_charge_only(Charge.NONE, duration)
	await _tween_charge_and_shield(Charge.NONE, Shield.OFF, duration, 2.0)
	powering_up = false
	return

func power_off(duration: float = 0.5, boost: float = 2.0) -> void:
	powering_down = true
	turn_off_lightning()
	_tween_shield_only(Shield.OFF, duration)
	_tween_charge_only(Charge.OFF, duration)
	await _tween_charge_and_shield(Charge.OFF, Shield.OFF, duration, boost)
	powering_down = false
	return
