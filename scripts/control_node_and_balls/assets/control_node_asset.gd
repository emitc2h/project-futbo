extends Node3D
class_name ControlNodeAsset

@onready var control_node_mesh: MeshInstance3D = $ControlNodeModel/ControlNodeMesh
@onready var shield_mesh: MeshInstance3D = $ControlNodeModel/ShieldMesh

@onready var shield_material: ShaderMaterial = $ControlNodeModel/ShieldMesh.get_surface_override_material(0)
@onready var emitters_material: ShaderMaterial = $ControlNodeModel/ControlNodeMesh.get_surface_override_material(0).next_pass

@onready var light: OmniLight3D = $Light

@onready var wisps_particles: GPUParticles3D = $WispParticles3D
@onready var lightning_particles: GPUParticles3D = $LightningParticles3D
@onready var lightning_material: ShaderMaterial = lightning_particles.draw_pass_1.surface_get_material(0)

@onready var aura_mesh: MeshInstance3D = $Aura
@onready var aura_material: StandardMaterial3D = aura_mesh.get_surface_override_material(0)

var power_on: bool = false
const blue: Color = Color.STEEL_BLUE
const black: Color = Color.BLACK
const magenta: Color = Color.MAGENTA

signal power_up_finished

## Properties Data Structure
func apply_props(props: ControlNodeProps) -> void:
	## Apply Shield Emitters properties
	emitters_material.set_shader_parameter("emission_color", props.emitter_emission_color)
	emitters_material.set_shader_parameter("emission_energy", props.emitter_emission_energy)

	## Apply Light properties
	light.set("light_energy", props.light_energy)
	light.set("light_color", props.light_color)
	
	## Apply Shield Shader material properties
	shield_material.set_shader_parameter("alpha", props.shield_alpha)
	shield_material.set_shader_parameter("dissolve_value", props.shield_dissolve_value)
	shield_material.set_shader_parameter("emission_energy", props.shield_emission_energy)
	shield_material.set_shader_parameter("ripple_strength", props.shield_ripple_strength)
	shield_material.set_shader_parameter("modulate", props.shield_modulate_color)
	shield_material.set_shader_parameter("modulate_factor", props.shield_modulate_factor)

	## Apply Shield Mesh properties
	shield_mesh.scale = props.shield_scale * Vector3.ONE
	
	## Apply Lightning Properties
	lightning_material.set_shader_parameter("lightning_window_size", props.lightning_window_size)
	lightning_particles.set("amount_ratio", props.lightning_amount_ratio)
	lightning_material.set_shader_parameter("lightning_emission_factor", props.lightning_emission_factor)
	lightning_material.set_shader_parameter("lightning_reverse", props.lightning_reverse)
	
	## Apply aura properties
	aura_material.albedo_color = props.aura_color
	aura_mesh.scale = props.aura_scale * Vector3.ONE


## Create state props
@onready var shield_off: ControlNodeProps = $ShieldOffProps
@onready var shield_on: ControlNodeProps = $ShieldOnProps
@onready var shield_expanded: ControlNodeProps = $ShieldExpandedProps
@onready var shield_blown: ControlNodeProps = $ShieldBlownProps

@onready var shield_charge_1: ControlNodeProps = $ShieldCharge1Props
@onready var shield_charge_2: ControlNodeProps = $ShieldCharge2Props
@onready var shield_charge_3: ControlNodeProps = $ShieldCharge3Props

var current_default_props: ControlNodeProps = shield_off

func _ready() -> void:
	## CHARGE LEVEL 1
	shield_charge_1.emitter_emission_color = blue
	shield_charge_1.emitter_emission_energy = 1000.0
	shield_charge_1.light_energy = 15.0
	shield_charge_1.shield_alpha = 1.0
	shield_charge_1.shield_dissolve_value = 1.0
	shield_charge_1.shield_emission_energy = 40.0
	shield_charge_1.shield_ripple_strength = 0.03
	shield_charge_1.shield_modulate_color = magenta
	shield_charge_1.shield_modulate_factor = 0.1
	shield_charge_1.shield_scale = 1.0
	
	apply_props(shield_off)


################################
##        ANIMATIONS         ##
###############################
func power_up_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	shield_material.set("shader_parameter/alpha", 1.0)
	shield_mesh.scale = Vector3.ONE
	
	tween1.tween_property(emitters_material, "shader_parameter/emission_color", shield_on.emitter_emission_color, 0.8)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)

	tween2.tween_property(emitters_material, "shader_parameter/emission_energy", shield_on.emitter_emission_energy, 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	tween3.tween_property(light, "light_energy", shield_on.light_energy, 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	tween2.tween_property(shield_material, "shader_parameter/dissolve_value", shield_on.shield_dissolve_value, 1.2)
	
	await tween2.finished
	wisps_particles.emitting = true
	apply_props(shield_on)
	current_default_props = shield_on
	power_up_finished.emit()
	power_on = true


func power_down_shield(speed_factor:float = 1.0) -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/dissolve_value", shield_off.shield_dissolve_value, 0.5 / speed_factor)
	
	tween1.tween_property(emitters_material, "shader_parameter/emission_energy", shield_off.emitter_emission_energy, 0.4 / speed_factor)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)
		
	tween2.tween_property(emitters_material, "shader_parameter/emission_color", shield_off.emitter_emission_color, 1.8 / speed_factor)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
	tween3.tween_property(light, "light_energy", shield_off.light_energy, 1.5 / speed_factor)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	
	await tween2.finished
	apply_props(shield_off)
	current_default_props = shield_off
	power_on = false


func bounce(bounce_strength: float) -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/emission_energy", current_default_props.shield_emission_energy, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(current_default_props.shield_emission_energy * 25.0 * bounce_strength)
		
	tween2.tween_property(shield_material, "shader_parameter/ripple_strength", current_default_props.shield_ripple_strength, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(current_default_props.shield_ripple_strength * 5.0 * bounce_strength)
	
	tween3.tween_property(light, "light_energy", current_default_props.light_energy, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(current_default_props.light_energy * 2.0 * bounce_strength)
	
	await tween3.finished
	apply_props(current_default_props)


func expand_shield() -> void:
	apply_props(shield_on)
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/ripple_strength", 2.0, 2.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
		
	tween2.tween_property(shield_material, "shader_parameter/emission_energy", 3000.0, 2.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	tween3.tween_property(shield_mesh, "scale", Vector3(1.0, 1.0, 1.0), 2.0)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
	
	tween1.tween_property(shield_material, "shader_parameter/ripple_strength", shield_expanded.shield_ripple_strength, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
		
	tween2.tween_property(shield_material, "shader_parameter/emission_energy", shield_expanded.shield_emission_energy, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	tween3.tween_property(shield_mesh, "scale", shield_expanded.shield_scale * Vector3.ONE, 1.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
		
	await tween3.finished
	apply_props(shield_expanded)
	current_default_props = shield_expanded


func shrink_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_mesh, "scale", shield_on.shield_scale * Vector3.ONE, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", 0.05, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", shield_on.shield_alpha, 0.9)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
	
	tween3.tween_property(shield_material, "shader_parameter/ripple_strength", 1.0, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	
	tween3.tween_property(shield_material, "shader_parameter/ripple_strength", shield_on.shield_ripple_strength, 0.9)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)
		
	await tween3.finished
	current_default_props = shield_on
	apply_props(shield_on)


func blow_shield() -> void:
	## Overlay the bounce animation
	self.bounce(2.0)
	
	## Trigger the particles
	wisps_particles.emitting = true
	
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_mesh, "scale", shield_blown.shield_scale, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", shield_blown.shield_alpha, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	
	tween3.tween_property(shield_material, "shader_parameter/dissolve_value", shield_blown.shield_dissolve_value, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
		
	await tween1.finished
	self.power_down_shield(3.0)


func charge_level_1() -> void:
	current_default_props = shield_charge_1
	apply_props(shield_charge_1)


func charge_level_2() -> void:
	current_default_props = shield_charge_2
	apply_props(shield_charge_2)


func charge_level_3() -> void:
	current_default_props = shield_charge_3
	apply_props(shield_charge_3)


func discharge() -> void:
	if power_on:
		current_default_props = shield_on
		apply_props(shield_on)
	else:
		current_default_props = shield_off
		apply_props(shield_off)
