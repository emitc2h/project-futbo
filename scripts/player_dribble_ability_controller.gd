class_name PlayerDribbleAbilityController
extends Node2D

@export var player_dribble_ability: PlayerDribbleAbility

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("dribble"):
		player_dribble_ability.start_dribble()
	
	if Input.is_action_just_released("dribble"):
		player_dribble_ability.end_dribble()
