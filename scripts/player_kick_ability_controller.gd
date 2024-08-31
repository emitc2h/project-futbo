class_name PlayerKickAbilityController
extends Node2D

@export var player_kick_ability: PlayerKickAbility

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("kick"):
		player_kick_ability.kick()
