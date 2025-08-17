class_name DroneEMSpinnersAnimation
extends Node

## Inject drone dependency to pass it to the physical bones
@export var model: DroneModel

## EM Spinner Animation Properties
@onready var spinners_off_props: DroneEMSpinnersProps = $EMSpinnersOffProps
@onready var spinners_charged_props: DroneEMSpinnersProps = $EMSpinnersChargedProps
@onready var spinners_fire_props: DroneEMSpinnersProps = $EMSpinnersFireProps
@onready var spinners_discharged_props: DroneEMSpinnersProps = $EMSpinnersDishargedProps

## Main Drone Model Mesh
var drone_mesh: MeshInstance3D

## EM Spinner Balls
var spinner_balls_material: ShaderMaterial

## EM Spinner Streaks
var spinner_streaks_material: ShaderMaterial

## EM Spinner Beams
var spinner_beams_material: ShaderMaterial

## Auras
var spinner_aura_left_mesh: MeshInstance3D
var spinner_aura_left_material: StandardMaterial3D

var spinner_aura_right_mesh: MeshInstance3D
var spinner_aura_right_material: StandardMaterial3D

## Tweens
var aura_left_tween: Tween
var aura_right_tween: Tween
var balls_tween: Tween
var streaks1_tween: Tween
var streaks2_tween: Tween
var streaks3_tween: Tween
var beams1_tween: Tween
var beams2_tween: Tween


func _ready() -> void:
	## Retrieve meshes
	drone_mesh = model.get_node("Armature/Skeleton3D/drone")
	spinner_aura_left_mesh = model.get_node("Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone DEF_PANEL_L/AuraLeft")
	spinner_aura_right_mesh = model.get_node("Armature/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone DEF_PANEL_R/AuraRight")
	
	## Retrieve materials
	spinner_balls_material = drone_mesh.get_surface_override_material(9)
	spinner_streaks_material = drone_mesh.get_surface_override_material(7)
	spinner_beams_material = drone_mesh.get_surface_override_material(8)
	spinner_aura_left_material = spinner_aura_left_mesh.get_surface_override_material(0)
	spinner_aura_right_material = spinner_aura_right_mesh.get_surface_override_material(0)
	
	## Initialize
	_apply_props(spinners_off_props)


## Properties Data Structure
func _apply_props(props: DroneEMSpinnersProps) -> void:
	## Apply Aura properties
	spinner_aura_left_material.albedo_color = props.aura_color
	spinner_aura_right_material.albedo_color = props.aura_color
	
	## Apply Balls properties
	spinner_balls_material.set_shader_parameter("dissolve_value_in", props.balls_dissolve_in)
	
	## Apply Streaks properties
	spinner_streaks_material.set_shader_parameter("alpha", props.streaks_alpha)
	spinner_streaks_material.set_shader_parameter("dissolve_value_in", props.streaks_dissolve_in)
	spinner_streaks_material.set_shader_parameter("dissolve_value_out", props.streaks_dissolve_out)
	
	## Apply Beams properties
	spinner_beams_material.set_shader_parameter("dissolve_value_in", props.beams_dissolve_in)
	spinner_beams_material.set_shader_parameter("dissolve_value_out", props.beams_dissolve_out)


func _tween_spinners(
	initial_props: DroneEMSpinnersProps,
	final_props: DroneEMSpinnersProps,
	duration: float,
	aura_ease: Tween.EaseType,
	aura_trans: Tween.TransitionType,
	balls_ease: Tween.EaseType,
	balls_trans: Tween.TransitionType,
	streaks_ease: Tween.EaseType,
	streaks_trans: Tween.TransitionType,
	beams_ease: Tween.EaseType,
	beams_trans:Tween.TransitionType
	) -> void:
		
	## Initial state
	_apply_props(initial_props)
	
	## Auras
	if initial_props.aura_color != final_props.aura_color:
		if aura_left_tween: aura_left_tween.kill()
		aura_left_tween = get_tree().create_tween()
		aura_left_tween.tween_property(spinner_aura_left_material, "albedo_color", final_props.aura_color, duration)\
			.set_ease(aura_ease)\
			.set_trans(aura_trans)
		
		if aura_right_tween: aura_right_tween.kill()
		aura_right_tween = get_tree().create_tween()
		aura_right_tween.tween_property(spinner_aura_right_material, "albedo_color", final_props.aura_color, duration)\
			.set_ease(aura_ease)\
			.set_trans(aura_trans)
	
	## Balls
	if initial_props.balls_dissolve_in != final_props.balls_dissolve_in:
		if balls_tween: balls_tween.kill()
		balls_tween = get_tree().create_tween()
		balls_tween.tween_property(spinner_balls_material, "shader_parameter/dissolve_value_in", final_props.balls_dissolve_in, duration)\
			.set_ease(balls_ease)\
			.set_trans(balls_trans)
	
	## Streaks
	if initial_props.streaks_alpha != final_props.streaks_alpha:
		if streaks1_tween: streaks1_tween.kill()
		streaks1_tween = get_tree().create_tween()
		streaks1_tween.tween_property(spinner_streaks_material, "shader_parameter/alpha", final_props.streaks_alpha, duration)\
			.set_ease(streaks_ease)\
			.set_trans(streaks_trans)
	
	if initial_props.streaks_dissolve_in != final_props.streaks_dissolve_in:
		if streaks2_tween: streaks2_tween.kill()
		streaks2_tween = get_tree().create_tween()
		streaks2_tween.tween_property(spinner_streaks_material, "shader_parameter/dissolve_value_in", final_props.streaks_dissolve_in, duration)\
			.set_ease(streaks_ease)\
			.set_trans(streaks_trans)
	
	if initial_props.streaks_dissolve_out != final_props.streaks_dissolve_out:
		if streaks3_tween: streaks3_tween.kill()
		streaks3_tween = get_tree().create_tween()
		streaks3_tween.tween_property(spinner_streaks_material, "shader_parameter/dissolve_value_out", final_props.streaks_dissolve_out, duration)\
			.set_ease(streaks_ease)\
			.set_trans(streaks_trans)
	
	## Beams
	if initial_props.streaks_dissolve_in != final_props.streaks_dissolve_in:
		if beams1_tween: beams1_tween.kill()
		beams1_tween = get_tree().create_tween()
		beams1_tween.tween_property(spinner_beams_material, "shader_parameter/dissolve_value_in", final_props.beams_dissolve_in, duration)\
			.set_ease(beams_ease)\
			.set_trans(beams_trans)
	
	if initial_props.beams_dissolve_out != final_props.beams_dissolve_out:
		if beams2_tween: beams2_tween.kill()
		beams2_tween = get_tree().create_tween()
		beams2_tween.tween_property(spinner_beams_material, "shader_parameter/dissolve_value_out", final_props.beams_dissolve_out, duration)\
			.set_ease(beams_ease)\
			.set_trans(beams_trans)


func turn_off() -> void:
	if aura_left_tween: aura_left_tween.kill()
	if aura_right_tween: aura_right_tween.kill()
	if balls_tween: balls_tween.kill()
	if streaks1_tween: streaks1_tween.kill()
	if streaks2_tween: streaks2_tween.kill()
	if streaks3_tween: streaks3_tween.kill()
	if beams1_tween: beams1_tween.kill()
	if beams2_tween: beams2_tween.kill()
	
	_apply_props(spinners_off_props)


func charge(duration: float) -> void:
	_tween_spinners(
		spinners_off_props,
		spinners_charged_props,
		duration,
		Tween.EASE_IN,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN,
		Tween.TRANS_CIRC,
		Tween.EASE_IN,
		Tween.TRANS_CIRC
	)


func fire(duration: float) -> void:
	_tween_spinners(
		spinners_fire_props,
		spinners_discharged_props,
		duration,
		Tween.EASE_OUT,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT,
		Tween.TRANS_EXPO,
		Tween.EASE_OUT,
		Tween.TRANS_CIRC,
		Tween.EASE_IN,
		Tween.TRANS_CIRC
	)
