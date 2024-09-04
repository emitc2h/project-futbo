class_name PlayerBasicMovementController
extends Node2D

@export var controlled_player: ControlledPlayer
var player_basic_movement: PlayerBasicMovement

var enabled: bool = false

func _ready() -> void:
	player_basic_movement = controlled_player.player.get_node("PlayerBasicMovement")
	if player_basic_movement:
		enabled = true


func _physics_process(delta: float) -> void:
	if enabled:
		player_basic_movement.run(Input.get_axis("move_left", "move_right"))
		
		if Input.is_action_just_pressed("jump"):
			player_basic_movement.jump()
