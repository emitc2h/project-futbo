class_name DroneShield
extends AnimatableBody3D

@export var drone: Drone

@onready var drone_shield_asset: DroneShieldAsset = $DroneShieldAsset
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var particles: GPUParticles3D = $GPUParticles3D

var enabled: bool = true


func hit(emit_particles: bool = true) -> void:
	if enabled:
		drone_shield_asset.hit()
		if emit_particles:
			particles.restart()
			particles.emitting = true


func enable() -> void:
	enabled = true
	collision_shape.disabled = false


func disable() -> void:
	enabled = false
	collision_shape.disabled = true
