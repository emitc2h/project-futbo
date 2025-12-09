extends Node3D

@onready var dust_particles: GPUParticles3D = $DustParticles
@onready var dust_fuzzy_particles: GPUParticles3D = $FuzzyParticles

func _ready() -> void:
	dust_particles.one_shot = true
	dust_particles.emitting = true
	dust_fuzzy_particles.one_shot = true
	dust_fuzzy_particles.emitting = true


func _on_dust_particles_finished() -> void:
	await get_tree().create_timer(4.0).timeout
	dust_particles.queue_free()


func _on_fuzzy_particles_finished() -> void:
	await get_tree().create_timer(4.0).timeout
	dust_fuzzy_particles.queue_free()
