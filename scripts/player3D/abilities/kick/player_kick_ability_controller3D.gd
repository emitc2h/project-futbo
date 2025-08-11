class_name PlayerKickAbilityController3D
extends Node3D

@export var controller: Controller3D
var player_kick_ability: PlayerKickAbility3D
var player_dribble_ability: PlayerDribbleAbility3D

var kick_enabled: bool = false
var dribble_enabled: bool = false


func _ready() -> void:
	player_kick_ability = controller.player.get_node("PlayerKickAbility3D")
	if player_kick_ability:
		kick_enabled = true
	
	player_dribble_ability = controller.player.get_node("PlayerDribbleAbility3D")
	if player_dribble_ability:
		dribble_enabled = true


func _physics_process(delta: float) -> void:
	if kick_enabled:
		if player_kick_ability.is_in_ready_state:
		
			if Input.is_action_just_pressed("kick"):
				if dribble_enabled:
					player_dribble_ability.end_dribble()
				player_kick_ability.kick()
				
		if Input.is_action_just_pressed("kick"):
			player_kick_ability.kick_button_pressed()
			
		if Input.is_action_just_released("kick"):
			player_kick_ability.kick_button_released()
			
		
