class_name DronePlasmaBoltImpactAnimation
extends Node

## Inject dependencies
@export var bolt: DronePlasmaBolt

## Animation Properties
@onready var off_props: DronePlasmaBoltImpactProps = $ImpactOffProps
@onready var hit_props: DronePlasmaBoltImpactProps = $ImpactHitProps
@onready var faded_props: DronePlasmaBoltImpactProps = $ImpactFadedProps

## Plasma bolt impact mesh
var impact_mesh: MeshInstance3D

## Plasma bolt impact material
var impact_material: ShaderMaterial

## Tweens
var alpha_tween: Tween
var dissolve_in_tween: Tween
var dissolve_out_tween: Tween

func _ready() -> void:
	impact_mesh = bolt.get_node("DronePlasmaBoltModel/impact")
	impact_material = impact_mesh.get_surface_override_material(0)
	
	_apply_props(off_props)


func _apply_props(props: DronePlasmaBoltImpactProps) -> void:
	impact_material.set_shader_parameter("alpha", props.alpha)
	impact_material.set_shader_parameter("dissolve_value_in", props.dissolve_value_in)
	impact_material.set_shader_parameter("dissolve_value_out", props.dissolve_value_out)


func _tween_impact(
	initial_props: DronePlasmaBoltImpactProps,
	final_props: DronePlasmaBoltImpactProps,
	duration: float,
	ease: Tween.EaseType,
	trans: Tween.TransitionType
	) -> void:
		
	## Initial state
	_apply_props(initial_props)

	if initial_props.alpha != final_props.alpha:
		if alpha_tween: alpha_tween.kill()
		alpha_tween = get_tree().create_tween()
		alpha_tween.tween_property(impact_material, "shader_parameter/alpha", final_props.alpha, duration)\
			.set_ease(ease)\
			.set_trans(trans)

	if initial_props.dissolve_value_in != final_props.dissolve_value_in:
		if dissolve_in_tween: dissolve_in_tween.kill()
		dissolve_in_tween = get_tree().create_tween()
		dissolve_in_tween.tween_property(impact_material, "shader_parameter/dissolve_value_in", final_props.dissolve_value_in, duration)\
			.set_ease(ease)\
			.set_trans(trans)
	
	if initial_props.dissolve_value_out != final_props.dissolve_value_out:
		if dissolve_out_tween: dissolve_out_tween.kill()
		dissolve_out_tween = get_tree().create_tween()
		dissolve_out_tween.tween_property(impact_material, "shader_parameter/dissolve_value_out", final_props.dissolve_value_out, duration)\
			.set_ease(ease)\
			.set_trans(trans)
	
	await alpha_tween.finished
	return


func hit() -> void:
	await _tween_impact(off_props, hit_props, 0.15, Tween.EASE_IN, Tween.TRANS_LINEAR)
	_tween_impact(hit_props, faded_props, 0.3, Tween.EASE_IN, Tween.TRANS_CUBIC)
