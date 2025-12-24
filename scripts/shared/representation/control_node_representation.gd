class_name ControlNodeRepresentation
extends Resource

@export var global_position: Vector3
@export var velocity: Vector3
@export var power_on: bool
@export var charges: int
@export var shield_expanded: bool

func _init(
	p_global_position: Vector3 = Vector3.ZERO,
	p_velocity: Vector3 = Vector3.ZERO,
	p_power_on: bool = false,
	p_charges: int = 0,
	p_shield_expanded: bool = false
) -> void:
	global_position = p_global_position
	velocity = p_velocity
	power_on = p_power_on
	charges = p_charges
	shield_expanded = p_shield_expanded
