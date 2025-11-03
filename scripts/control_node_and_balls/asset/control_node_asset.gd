extends Node3D
class_name ControlNodeAsset

## Wisps (needs to be placed in the TrackPositionContainer, so inject dependency)
@export var wisps_particles: GPUParticles3D

## Aura
@onready var aura_mesh: MeshInstance3D = $Aura
var aura_material: StandardMaterial3D

## Shield Mesh and Material
@onready var shield_mesh: MeshInstance3D = $ControlNodeModel/ShieldMesh
var shield_material: ShaderMaterial

## Light
@onready var light: OmniLight3D = $Light

## Ready Sphere (needs to be placed in the TrackPositionContainer, so inject dependency)
@export var ready_sphere: ControlNodeReadySphere

const blue: Color = Color.STEEL_BLUE
const black: Color = Color.BLACK
const magenta: Color = Color.LIGHT_PINK

## Bounce tweens
var tw_shield_emission_energy: Tween
var tw_shield_ripple_strength: Tween
var tw_light_energy: Tween


func _ready() -> void:
	shield_material = shield_mesh.get_surface_override_material(0)
	ready_sphere.visible = false
	turn_off_ready_sphere()


################################
##        ANIMATIONS         ##
################################
func turn_on_ready_sphere() -> void:
	ready_sphere.visible = true
	aura_mesh.visible = false


func turn_off_ready_sphere() -> void:
	ready_sphere.visible = false
	aura_mesh.visible = true


func blue_wisps() -> void:
	wisps_particles.process_material.color = blue
	wisps_particles.emitting = true


func magenta_wisps() -> void:
	wisps_particles.process_material.color = magenta
	wisps_particles.emitting = true


func bounce(bounce_strength: float) -> void:
	if tw_shield_emission_energy: tw_shield_emission_energy.kill()
	
	var current_shield_emission_energy: float = shield_material.get("shader_parameter/emission_energy")
	tw_shield_emission_energy = create_tween()
	tw_shield_emission_energy.tween_property(shield_material, "shader_parameter/emission_energy", current_shield_emission_energy, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(current_shield_emission_energy * 25.0 * bounce_strength)

	var current_shield_ripple_strength: float = shield_material.get("shader_parameter/ripple_strength")
	if tw_shield_ripple_strength: tw_shield_ripple_strength.kill()
	tw_shield_ripple_strength = create_tween()
	tw_shield_ripple_strength.tween_property(shield_material, "shader_parameter/ripple_strength", current_shield_ripple_strength, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(current_shield_ripple_strength * 5.0 * bounce_strength)

	var current_light_energy: float = light.light_energy
	if tw_light_energy: tw_light_energy.kill()
	tw_light_energy = create_tween()
	tw_light_energy.tween_property(light, "light_energy", current_light_energy, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(current_light_energy * 2.0 * bounce_strength)
