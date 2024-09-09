class_name PlayerDribbleAbilityController
extends Node2D

@export var controller: Controller
var player_dribble_ability: PlayerDribbleAbility
var player_basic_movement: PlayerBasicMovement

var enabled: bool = false


func _ready() -> void:
	player_basic_movement = controller.player.get_node("PlayerBasicMovement")
	player_dribble_ability = controller.player.get_node("PlayerDribbleAbility")
	if player_dribble_ability:
		enabled = true


func _physics_process(delta: float) -> void:
	if enabled:
		if Input.is_action_just_pressed("dribble"):
			player_dribble_ability.start_dribble()
	
		if Input.is_action_just_released("dribble"):
			player_dribble_ability.end_dribble()
			
		if Input.is_action_just_pressed("jump"):
			player_dribble_ability.ball_jump(player_basic_movement.jump_momentum)
