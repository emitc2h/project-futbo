class_name DroneShield
extends AnimatableBody3D

@export var drone: Drone

@onready var drone_shield_closed_model: DroneClosedShieldModel = $DroneClosedShieldModel
@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var particles: GPUParticles3D = $GPUParticles3D

var _enabled: bool = true
var enabled: bool:
	get:
		return _enabled
	set(value):
		_enabled = value
		collision_shape.disabled = !value
		

func hit() -> void:
	drone_shield_closed_model.hit()
	particles.restart()
	particles.emitting = true
