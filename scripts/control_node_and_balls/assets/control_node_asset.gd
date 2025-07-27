extends Node3D
class_name ControlNodeAsset

@onready var control_node_mesh: MeshInstance3D = $ControlNodeModel/ControlNodeMesh
@onready var shield_mesh: MeshInstance3D = $ControlNodeModel/ShieldMesh

@onready var shield_material: ShaderMaterial = $ControlNodeModel/ShieldMesh.get_surface_override_material(0)
@onready var emitters_material: ShaderMaterial = $ControlNodeModel/ControlNodeMesh.get_surface_override_material(0).next_pass

@onready var light: OmniLight3D = $Light

@onready var wisps_particles: GPUParticles3D = $WispParticles3D

var power_on: bool = false
var blue: Color = Color.STEEL_BLUE
var black: Color = Color.BLACK

signal power_up_finished

func power_up_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	shield_material.set("shader_parameter/alpha", 1.0)
	shield_mesh.scale = Vector3.ONE
	
	tween1.tween_property(emitters_material, "shader_parameter/emission_color", blue, 0.8)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN)\
		.from(black)
	tween2.tween_property(emitters_material, "shader_parameter/emission_energy", 1000.0, 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(0.0)
	tween3.tween_property(light, "light_energy", 10.0, 1.5)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(0.0)
	tween2.tween_property(shield_material, "shader_parameter/dissolve_value", 1.0, 1.2)\
		.from(0.0)
	
	await tween2.finished
	wisps_particles.emitting = true
	power_up_finished.emit()
	power_on = true

func power_down_shield(speed_factor:float = 1.0) -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/dissolve_value", 0.0, 0.5 / speed_factor)\
		.from(1.0)
	tween1.tween_property(emitters_material, "shader_parameter/emission_energy", 0.0, 0.4 / speed_factor)\
		.set_trans(Tween.TRANS_QUINT)\
		.set_ease(Tween.EASE_OUT)\
		.from(1000.0)
	tween2.tween_property(emitters_material, "shader_parameter/emission_color", black, 1.8 / speed_factor)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(blue)
	tween3.tween_property(light, "light_energy", 0.0, 1.5 / speed_factor)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(10.0)
	power_on = false


func bounce(bounce_strength: float) -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/emission_energy", 20.0, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(500.0 * bounce_strength)
		
	tween2.tween_property(shield_material, "shader_parameter/ripple_strength", 0.02, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(0.2 * bounce_strength)
	
	tween3.tween_property(light, "light_energy", 10.0, 0.5 * bounce_strength)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(20.0 * bounce_strength)

func expand_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_material, "shader_parameter/ripple_strength", 2.0, 2.0)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(0.02)
		
	tween2.tween_property(shield_material, "shader_parameter/emission_energy", 3000.0, 2.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(20.0)
		
	tween3.tween_property(shield_mesh, "scale", Vector3(1.0, 1.0, 1.0), 2.0)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3(1.0, 1.0, 1.0))
	
	tween1.tween_property(shield_material, "shader_parameter/ripple_strength", 0.01, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)\
		.from(1.0)
		
	tween2.tween_property(shield_material, "shader_parameter/emission_energy", 20.0, 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)\
		.from(3000.0)
	
	tween3.tween_property(shield_mesh, "scale", Vector3(11.0, 11.0, 11.0), 1.0)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3(1.0, 1.0, 1.0))


func shrink_shield() -> void:
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_mesh, "scale", Vector3(1.0, 1.0, 1.0), 1.0)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)\
		.from(Vector3(11.0, 11.0, 11.0))
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", 0.05, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)\
		.from(1.0)
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", 1.0, 0.9)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(0.05)
	
	tween3.tween_property(shield_material, "shader_parameter/ripple_strength", 1.0, 0.1)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)\
		.from(0.01)
	
	tween3.tween_property(shield_material, "shader_parameter/ripple_strength", 0.02, 0.9)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_IN)\
		.from(1.0)

func blow_shield() -> void:
	
	## Overlay the bounce animation
	self.bounce(2.0)
	
	## Trigger the particles
	wisps_particles.emitting = true
	
	var tween1: Tween = get_tree().create_tween()
	var tween2: Tween = get_tree().create_tween()
	var tween3: Tween = get_tree().create_tween()
	
	tween1.tween_property(shield_mesh, "scale", Vector3(2.5, 2.5, 2.5), 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3(1.0, 1.0, 1.0))
	
	tween2.tween_property(shield_material, "shader_parameter/alpha", 0.0, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)\
		.from(1.0)
	
	tween3.tween_property(shield_material, "shader_parameter/dissolve_value", 0.0, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)\
		.from(1.0)
		
	await tween1.finished
	self.power_down_shield(3.0)
