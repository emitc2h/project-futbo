class_name PlayerKickAbilityController
extends Node2D

@export var controller: Controller
var player_kick_ability: PlayerKickAbility
var player_dribble_ability: PlayerDribbleAbility

var kick_enabled: bool = false
var dribble_enabled: bool = false


func _ready() -> void:
	player_kick_ability = controller.player.get_node("PlayerKickAbility")
	if player_kick_ability:
		kick_enabled = true
	
	player_dribble_ability = controller.player.get_node("PlayerDribbleAbility")
	if player_dribble_ability:
		dribble_enabled = true


func _physics_process(delta: float) -> void:
	if kick_enabled and player_kick_ability.is_ready:
		player_kick_ability.aim = \
			Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		
		if Input.is_action_just_pressed("kick"):
			if dribble_enabled:
				player_dribble_ability.end_dribble()
			player_kick_ability.kick()
