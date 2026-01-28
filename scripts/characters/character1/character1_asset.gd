class_name Character1Asset
extends CharacterAssetBase

## Handle on Character Mesh Materials
@export_group("Dependencies")
@export_subgroup("Mesh Materials")
@export var shield_material: ShaderMaterial
@export var emitters_material: ShaderMaterial
@export var jump_distortion_material: ShaderMaterial
@export var jump_flare_material: ShaderMaterial
@export_subgroup("Lights")
@export var lights: Array[OmniLight3D]
@export_subgroup("Auras")
@export var aura_meshes: Array[MeshInstance3D]
@export var aura_material: StandardMaterial3D
@export_subgroup("Lightning")
@export var lightning_particles: GPUParticles3D
@export var lightning_material: ShaderMaterial

## Handle on AnimationPlayer
@onready var jump_anim_player: AnimationPlayer = $JumpAnimationPlayer
@onready var shield_anim_player: AnimationPlayer = $ShieldAnimationPlayer

## Consolidate animated parameters
@export_group("Jump Effect")
@export var jump_effect_stretch: float:
	get:
		return jump_distortion_material.get_shader_parameter("stretch")
	set(value):
		jump_distortion_material.set_shader_parameter("stretch", value)
		jump_flare_material.set_shader_parameter("stretch", value)

@export var jump_effect_noise_intensity: float:
	get:
		return jump_distortion_material.get_shader_parameter("noise_intensity")
	set(value):
		jump_distortion_material.set_shader_parameter("noise_intensity", value)
		jump_flare_material.set_shader_parameter("noise_intensity", value)

@export var jump_effect_noise_speed: float:
	get:
		return jump_distortion_material.get_shader_parameter("noise_speed")
	set(value):
		jump_distortion_material.set_shader_parameter("noise_speed", value)
		jump_flare_material.set_shader_parameter("noise_speed", value)

@export var jump_effect_visible: bool:
	get:
		return jump_distortion_material.get_shader_parameter("enabled")
	set(value):
		jump_distortion_material.set_shader_parameter("enabled", value)
		jump_flare_material.set_shader_parameter("enabled", value)

@export var jump_effect_flare_threshold: float:
	get:
		return jump_flare_material.get_shader_parameter("flare_threshold")
	set(value):
		jump_flare_material.set_shader_parameter("flare_threshold", value)


@export_group("Shield Materials")
@export_subgroup("Emitters")
@export var emitters_emission: float:
	get:
		return emitters_material.get_shader_parameter("emission_energy")
	set(value):
		emitters_material.set_shader_parameter("emission_energy", value)

@export var emitters_color: Color:
	get:
		return emitters_material.get_shader_parameter("emission_color")
	set(value):
		emitters_material.set_shader_parameter("emission_color", value)


@export_subgroup("Shield")
@export var shield_dissolve: float:
	get:
		return shield_material.get_shader_parameter("dissolve_value")
	set(value):
		shield_material.set_shader_parameter("dissolve_value", value)

@export var shield_alpha: float:
	get:
		return shield_material.get_shader_parameter("alpha")
	set(value):
		shield_material.set_shader_parameter("alpha", value)

@export var shield_modulate: float:
	get:
		return shield_material.get_shader_parameter("modulate_factor")
	set(value):
		shield_material.set_shader_parameter("modulate_factor", value)

@export var shield_emission: float:
	get:
		return shield_material.get_shader_parameter("emission_energy")
	set(value):
		shield_material.set_shader_parameter("emission_energy", value)

@export var shield_ripple: float:
	get:
		return shield_material.get_shader_parameter("ripple_strength")
	set(value):
		shield_material.set_shader_parameter("ripple_strength", value)

@export_subgroup("Auras")
@export var aura_scale: float:
	get:
		return aura_meshes[0].scale.x
	set(value):
		for aura in aura_meshes:
			aura.scale = Vector3.ONE * value

@export var aura_color: Color:
	get:
		return aura_material.albedo_color
	set(value):
		aura_material.albedo_color = value

@export var aura_visible: bool:
	get:
		return aura_meshes[0].visible
	set(value):
		for aura in aura_meshes:
			aura.visible = value


@export_subgroup("Lights")
@export var light_energy: float:
	get:
		return lights[0].light_energy
	set(value):
		for light in lights:
			light.light_energy = value

@export var light_color: Color:
	get:
		return lights[0].light_color
	set(value):
		for light in lights:
			light.light_color = value


@export_subgroup("Lightning")
@export var lightning_amount_ratio: float:
	get:
		return lightning_particles.amount_ratio
	set(value):
		if lightning_particles:
			lightning_particles.amount_ratio = value

@export var lightning_emission: float:
	get:
		return lightning_material.get_shader_parameter("emission_factor")
	set(value):
		lightning_material.set_shader_parameter("emission_factor", value)

@export var lightning_window: float:
	get:
		return lightning_material.get_shader_parameter("window_size")
	set(value):
		lightning_material.set_shader_parameter("window_size", value)

@export var lightning_reverse: bool:
	get:
		return lightning_material.get_shader_parameter("reverse")
	set(value):
		lightning_material.set_shader_parameter("reverse", value)
		

func _ready() -> void:
	super._ready()
	
	## Auto-transitions
	shield_anim_player.playback_auto_capture = false
	shield_anim_player.playback_auto_capture_duration = 0.1
	shield_anim_player.playback_auto_capture_ease_type = Tween.EASE_IN
	shield_anim_player.playback_auto_capture_transition_type = Tween.TRANS_CIRC
	
	shield_anim_player.play("RESET")
	shield_anim_player.play("state - off")


#=======================================================
# CONTROLS
#=======================================================
func jump() -> void:
	super.jump()
	jump_anim_player.play("jump")
