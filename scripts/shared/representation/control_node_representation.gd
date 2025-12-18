class_name ControlNodeRepresentation
extends Resource

@export var global_position: Vector3
@export var velocity: Vector3
@export var power_on: bool
@export var shield_charges: int

func _init(
	p_global_position: Vector3 = Vector3.ZERO,
	p_velocity: Vector3 = Vector3.ZERO,
	p_power_on: bool = false,
	p_shield_charges: int = 0,
) -> void:
	global_position = p_global_position
	velocity = p_velocity
	power_on = p_power_on
	shield_charges = p_shield_charges
