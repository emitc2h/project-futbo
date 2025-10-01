class_name CharacterBase
extends CharacterBody3D

## state machines
@export_group("State Machines")
@export var direction_states: CharacterDirectionFacedStates

@export var movement_states: CharacterMovementStates
@export var grounded_states: CharacterGroundedStates
@export var in_the_air_states: CharacterInTheAirStates
@export var path_states: CharacterPathStates

@export var damage_states: CharacterDamageStates

func move(left_right_axis: float) -> void:
	pass
