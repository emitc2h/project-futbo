class_name ControlNodeStreak
extends Node3D

## Parameters
@export var streak_out_duration_multiplier: float = 3.0
@export var strike_duration_multiplier: float = 2.0
@export var ring_duration_multiplier: float = 5.0
@export var ring_initial_scale: float = 0.1
@export var ring_final_scale: float = 1.0

## Skeleton
@onready var skeleton: Skeleton3D = $Armature/Skeleton3D

## Aura
@onready var aura_mesh: MeshInstance3D = $Aura
var aura_material: StandardMaterial3D
var aura_color: Color

## Streak
@onready var streak_mesh: MeshInstance3D = $Armature/Skeleton3D/streak
var streak_material: ShaderMaterial

## Ring
@onready var ring_mesh: MeshInstance3D = $ring
var ring_material: ShaderMaterial

## Shrapnel
@onready var shrapnel_particles: GPUParticles3D = $ShrapnelParticles3D


## Internal variables
var duration: float = 1.0


func _ready() -> void:
	## Aura setup
	aura_material = aura_mesh.get_surface_override_material(0)
	aura_color = aura_material.albedo_color
	aura_material.albedo_color = Color.TRANSPARENT
	aura_mesh.scale = Vector3.ONE
	aura_mesh.visible = false
	
	## Streak setup
	streak_material = streak_mesh.get_surface_override_material(0)
	streak_material.set_shader_parameter("dissolve_value_in", 1.0)
	streak_material.set_shader_parameter("dissolve_value_out", 0.0)
	streak_mesh.visible = false

	## Ring setup
	ring_material = ring_mesh.get_surface_override_material(0)
	ring_material.set_shader_parameter("dissolve_value_in", 0.0)
	ring_material.set_shader_parameter("dissolve_value_out", 1.0)
	ring_mesh.scale = Vector3.ONE * ring_initial_scale
	ring_mesh.visible = false


var start_position: Vector3:
	get:
		return skeleton.get_bone_pose_position(0)
	set(value):
		skeleton.set_bone_pose_position(0, value)
		skeleton.set_bone_pose_rotation(0, _get_streak_rotation())
		skeleton.set_bone_pose_rotation(1, _get_streak_rotation())

var end_position: Vector3:
	get:
		return skeleton.get_bone_pose_position(1)
	set(value):
		ring_mesh.position = value
		ring_mesh.quaternion = _get_streak_rotation(Vector3.UP)
		
		aura_mesh.position = value
		
		shrapnel_particles.position = value
		shrapnel_particles.quaternion = _get_streak_rotation(Vector3.DOWN)
		
		skeleton.set_bone_pose_position(1, value)
		skeleton.set_bone_pose_rotation(0, _get_streak_rotation())
		skeleton.set_bone_pose_rotation(1, _get_streak_rotation())

var start_scale: float:
	get:
		return skeleton.get_bone_pose_scale(0).x
	set(value):
		skeleton.set_bone_pose_scale(0, Vector3.ONE * value)

var end_scale: float:
	get:
		return skeleton.get_bone_pose_scale(1).x
	set(value):
		skeleton.set_bone_pose_scale(1, Vector3.ONE * value)


func _get_streak_rotation(from_vector: Vector3 = Vector3.LEFT) -> Quaternion:
	var direction_vector: Vector3 = end_position - start_position
	return Quaternion(from_vector, direction_vector)


# control functions
#----------------------------------------
func streak_in() -> void:
	streak_mesh.visible = true
	streak_material.set_shader_parameter("dissolve_value_in", 1.0)
	streak_material.set_shader_parameter("dissolve_value_out", 0.0)
	
	var dissolve_tween: Tween = get_tree().create_tween()
	var scale_tween: Tween = get_tree().create_tween()
	
	dissolve_tween.tween_property(streak_material, "shader_parameter/dissolve_value_out", 1.0, duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(0.0)
	
	scale_tween.tween_property(self, "start_scale", 0.4, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(1.0)


func streak_out() -> void:	
	streak_material.set_shader_parameter("dissolve_value_in", 1.0)
	streak_material.set_shader_parameter("dissolve_value_out", 1.0)
	
	var dissolve_tween_in: Tween = get_tree().create_tween()
	var dissolve_tween_out: Tween = get_tree().create_tween()
	
	dissolve_tween_in.tween_property(streak_material, "shader_parameter/dissolve_value_in", 0.0, streak_out_duration_multiplier * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(1.0)
	
	dissolve_tween_out.tween_property(streak_material, "shader_parameter/dissolve_value_out", 0.5, streak_out_duration_multiplier * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(1.0)
	
	await dissolve_tween_in.finished
	streak_mesh.visible = false


func strike() -> void:
	shrapnel_particles.emitting = true
	_strike_aura_tweens()
	_strike_ring_tweens()


func _strike_aura_tweens() -> void:
	aura_mesh.visible = true
	var aura_tween_color: Tween = get_tree().create_tween()
	var aura_tween_scale: Tween = get_tree().create_tween()
	
	aura_tween_color.tween_property(aura_material, "albedo_color", aura_color, strike_duration_multiplier * 0.2 * duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(Color.TRANSPARENT)
	
	aura_tween_scale.tween_property(aura_mesh, "scale", Vector3.ONE * 6.0, strike_duration_multiplier * 0.2 * duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(Vector3.ONE)
	
	aura_tween_color.tween_property(aura_material, "albedo_color", Color.TRANSPARENT, strike_duration_multiplier * 0.8 * duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(aura_color)
	
	aura_tween_scale.tween_property(aura_mesh, "scale", Vector3.ONE, strike_duration_multiplier * 0.8 * duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)\
		.from(Vector3.ONE * 6.0)

	await aura_tween_scale.finished
	aura_mesh.visible = false


func _strike_ring_tweens() -> void:
	ring_material.set_shader_parameter("dissolve_value_in", 0.0)
	ring_material.set_shader_parameter("dissolve_value_out", 1.0)
	ring_mesh.scale = Vector3.ONE * 0.2
	
	ring_mesh.visible = true
	var ring_dissolve_tween: Tween = get_tree().create_tween()
	var ring_scale_tween: Tween = get_tree().create_tween()
	
	ring_dissolve_tween.tween_property(ring_material, "shader_parameter/dissolve_value_in", 1.0, ring_duration_multiplier * 0.4 * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(0.0)
	
	ring_scale_tween.tween_property(ring_mesh, "scale", Vector3.ONE * ring_final_scale, ring_duration_multiplier * duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)\
		.from(Vector3.ONE * ring_initial_scale)
	
	ring_dissolve_tween.tween_property(ring_material, "shader_parameter/dissolve_value_out", 0.0, ring_duration_multiplier * 0.6 * duration)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(1.0)
	
	await ring_dissolve_tween.finished
	ring_mesh.visible = false
