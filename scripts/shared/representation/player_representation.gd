class_name PlayerRepresentation
extends Resource

@export var global_position: Vector3
@export var velocity: Vector3
@export var is_dribbling: bool
@export var is_dead: bool
@export var personal_shield_charges: int

func _init(
	p_global_position: Vector3 = Vector3.ZERO,
	p_velocity: Vector3 = Vector3.ZERO,
	p_is_dribbling: bool = false,
	p_is_dead: bool = false,
	p_personal_shield_charges: int = 0
	) -> void:
	global_position = p_global_position
	velocity = p_velocity
	is_dribbling = p_is_dribbling
	is_dead = p_is_dead
	personal_shield_charges = p_personal_shield_charges
