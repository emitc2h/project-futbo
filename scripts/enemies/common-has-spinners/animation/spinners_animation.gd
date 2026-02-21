class_name SpinnersAnimation
extends Node

## Inject dependency to pass it to the physical bones
@export var mesh: MeshInstance3D
@export var aura_meshes: Array[MeshInstance3D]
@export var fire_ball_material_index: int
@export var fire_streaks_material_index: int
@export var fire_beam_material_index: int

## EM Spinner Animation Properties
@onready var spinners_off_props: SpinnersProps = $SpinnersOffProps
@onready var spinners_charged_props: SpinnersProps = $SpinnersChargedProps
@onready var spinners_fire_props: SpinnersProps = $SpinnersFireProps
@onready var spinners_discharged_props: SpinnersProps = $SpinnersDishargedProps

## EM Spinner Balls
var fire_ball_material: ShaderMaterial

## EM Spinner Streaks
var fire_streaks_material: ShaderMaterial

## EM Spinner Beams
var fire_beam_material: ShaderMaterial

## Auras
var aura_materials: Array[StandardMaterial3D]

## Tweens
var aura_tweens: Array[Tween]
var balls_tween: Tween
var streaks1_tween: Tween
var streaks2_tween: Tween
var streaks3_tween: Tween
var beams1_tween: Tween
var beams2_tween: Tween


func _ready() -> void:
	## Retrieve materials
	fire_ball_material = mesh.get_surface_override_material(fire_ball_material_index)
	fire_streaks_material = mesh.get_surface_override_material(fire_streaks_material_index)
	fire_beam_material = mesh.get_surface_override_material(fire_beam_material_index)
	
	for aura_mesh in aura_meshes:
		aura_materials.append(aura_mesh.get_surface_override_material(0))
		## Prefill the tweens array
		aura_tweens.append(get_tree().create_tween())
	
	## Initialize
	_apply_props(spinners_off_props)


## Apply Properties
func _apply_props(props: SpinnersProps) -> void:
	## Apply Aura properties
	for aura_material in aura_materials:
		aura_material.albedo_color = props.aura_color
	
	## Apply Balls properties
	fire_ball_material.set_shader_parameter("dissolve_value_in", props.balls_dissolve_in)
	
	## Apply Streaks properties
	fire_streaks_material.set_shader_parameter("alpha", props.streaks_alpha)
	fire_streaks_material.set_shader_parameter("dissolve_value_in", props.streaks_dissolve_in)
	fire_streaks_material.set_shader_parameter("dissolve_value_out", props.streaks_dissolve_out)
	
	## Apply Beams properties
	fire_beam_material.set_shader_parameter("dissolve_value_in", props.beams_dissolve_in)
	fire_beam_material.set_shader_parameter("dissolve_value_out", props.beams_dissolve_out)


func _tween_spinners(
	initial_props: SpinnersProps,
	final_props: SpinnersProps,
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
		for i in aura_tweens.size():
			var aura_tween: Tween = aura_tweens[i]
			if aura_tween: aura_tween.kill()
			aura_tween = get_tree().create_tween()
			aura_tween.tween_property(aura_materials[i], "albedo_color", final_props.aura_color, duration)\
				.set_ease(aura_ease)\
				.set_trans(aura_trans)
	
	## Balls
	if initial_props.balls_dissolve_in != final_props.balls_dissolve_in:
		if balls_tween: balls_tween.kill()
		balls_tween = get_tree().create_tween()
		balls_tween.tween_property(fire_ball_material, "shader_parameter/dissolve_value_in", final_props.balls_dissolve_in, duration)\
			.set_ease(balls_ease)\
			.set_trans(balls_trans)
	
	## Streaks
	if initial_props.streaks_alpha != final_props.streaks_alpha:
		if streaks1_tween: streaks1_tween.kill()
		streaks1_tween = get_tree().create_tween()
		streaks1_tween.tween_property(fire_streaks_material, "shader_parameter/alpha", final_props.streaks_alpha, duration)\
			.set_ease(streaks_ease)\
			.set_trans(streaks_trans)
	
	if initial_props.streaks_dissolve_in != final_props.streaks_dissolve_in:
		if streaks2_tween: streaks2_tween.kill()
		streaks2_tween = get_tree().create_tween()
		streaks2_tween.tween_property(fire_streaks_material, "shader_parameter/dissolve_value_in", final_props.streaks_dissolve_in, duration)\
			.set_ease(streaks_ease)\
			.set_trans(streaks_trans)
	
	if initial_props.streaks_dissolve_out != final_props.streaks_dissolve_out:
		if streaks3_tween: streaks3_tween.kill()
		streaks3_tween = get_tree().create_tween()
		streaks3_tween.tween_property(fire_streaks_material, "shader_parameter/dissolve_value_out", final_props.streaks_dissolve_out, duration)\
			.set_ease(streaks_ease)\
			.set_trans(streaks_trans)
	
	## Beams
	if initial_props.streaks_dissolve_in != final_props.streaks_dissolve_in:
		if beams1_tween: beams1_tween.kill()
		beams1_tween = get_tree().create_tween()
		beams1_tween.tween_property(fire_beam_material, "shader_parameter/dissolve_value_in", final_props.beams_dissolve_in, duration)\
			.set_ease(beams_ease)\
			.set_trans(beams_trans)
	
	if initial_props.beams_dissolve_out != final_props.beams_dissolve_out:
		if beams2_tween: beams2_tween.kill()
		beams2_tween = get_tree().create_tween()
		beams2_tween.tween_property(fire_beam_material, "shader_parameter/dissolve_value_out", final_props.beams_dissolve_out, duration)\
			.set_ease(beams_ease)\
			.set_trans(beams_trans)


func turn_off() -> void:
	for aura_tween in aura_tweens:
		aura_tween.kill()
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
