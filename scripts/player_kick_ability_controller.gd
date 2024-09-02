class_name PlayerKickAbilityController
extends Node2D

@export var player_kick_ability: PlayerKickAbility

func _physics_process(delta: float) -> void:
		
	if player_kick_ability.is_ready:
		player_kick_ability.aim = \
			Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		if Input.is_action_just_pressed("kick"):
			player_kick_ability.kick()
