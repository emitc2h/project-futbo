extends Node3D

@export var final_shockwave_scale: float = 6.0

@onready var dust_particles: GPUParticles3D = $DustParticles
@onready var dust_fuzzy_particles: GPUParticles3D = $FuzzyParticles
@onready var shockwave_mesh: MeshInstance3D = $Shockwave
@onready var shockwave_material: ShaderMaterial = shockwave_mesh.get_surface_override_material(0)
@onready var hitbox_left: Area3D = $HitBoxLeft
@onready var hitbox_left_col: CollisionShape3D = $HitBoxLeft/CollisionShape3D
@onready var hitbox_right: Area3D = $HitBoxRight
@onready var hitbox_right_col: CollisionShape3D = $HitBoxRight/CollisionShape3D


func _ready() -> void:
	dust_particles.one_shot = true
	dust_particles.emitting = true
	dust_fuzzy_particles.one_shot = true
	dust_fuzzy_particles.emitting = true
	
	await _animate_shockwave(0.5)
	shockwave_mesh.queue_free()
	hitbox_left.queue_free()
	hitbox_right.queue_free()


func _on_dust_particles_finished() -> void:
	await get_tree().create_timer(3.0).timeout
	dust_particles.queue_free()


func _on_fuzzy_particles_finished() -> void:
	await get_tree().create_timer(3.0).timeout
	dust_fuzzy_particles.queue_free()


func _animate_shockwave(duration: float) -> void:
	hitbox_left_col.disabled = false
	hitbox_right_col.disabled = false
	shockwave_material.set_shader_parameter("alpha", 1.0)
	shockwave_material.set_shader_parameter("emission_energy", 25.0)
	shockwave_material.set_shader_parameter("dissolve_value_in", 0.0)
	shockwave_material.set_shader_parameter("dissolve_value_out", 1.0)
	shockwave_material.set_shader_parameter("burn_size", 0.05)
	shockwave_material.set_shader_parameter("burn_boost", 25.0)
	
	var tw_scale: Tween = create_tween()
	tw_scale.tween_property(shockwave_mesh, "scale", Vector3(final_shockwave_scale, 2.0, final_shockwave_scale), duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.from(Vector3(0.4, 1.0, 0.4))
	
	var tw_dissolve_in: Tween = create_tween()
	tw_dissolve_in.tween_property(shockwave_material, "shader_parameter/dissolve_value_in", 1.0, duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(0.0)
	
	var tw_dissolve_out: Tween = create_tween()
	tw_dissolve_out.tween_property(shockwave_material, "shader_parameter/dissolve_value_out", 0.0, duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(1.0)
	
	var tw_hb_left: Tween = create_tween()
	tw_hb_left.tween_property(hitbox_left, "position", Vector3(-(final_shockwave_scale + 0.05), 0.5, 0.0), duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.from(Vector3(-0.3, 0.5, 0.0))
	
	var tw_hb_right: Tween = create_tween()
	tw_hb_right.tween_property(hitbox_right, "position", Vector3(final_shockwave_scale + 0.05, 0.5, 0.0), duration)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_SINE)\
		.from(Vector3(0.3, 0.5, 0.0))
	
	await get_tree().create_timer(0.8 * duration).timeout
	hitbox_left_col.disabled = true
	hitbox_right_col.disabled = true
	
	await tw_scale.finished


func _on_hit_box_left_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerGroup"):
		Signals.player_takes_damage.emit(Vector3.LEFT * 3.0, global_position, true)


func _on_hit_box_right_body_entered(body: Node3D) -> void:
	if body.is_in_group("PlayerGroup"):
		Signals.player_takes_damage.emit(Vector3.RIGHT * 3.0, global_position, true)
