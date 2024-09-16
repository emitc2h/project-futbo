class_name PlayerDribbleAbilityController3D
extends Node3D

@export var controller: Controller3D
var player_dribble_ability: PlayerDribbleAbility3D
var player_basic_movement: PlayerBasicMovement3D

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
