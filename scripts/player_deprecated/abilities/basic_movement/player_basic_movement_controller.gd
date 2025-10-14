class_name PlayerBasicMovementController
extends Node3D

@export var controller: Controller
var player_basic_movement: PlayerBasicMovement

var enabled: bool = false

func _ready() -> void:
	player_basic_movement = controller.player.get_node("PlayerBasicMovement")
	if player_basic_movement:
		enabled = true


func _physics_process(_delta: float) -> void:
	if enabled:
		player_basic_movement.run(Input.get_axis("move_left", "move_right"))
		
		if Input.is_action_just_pressed("jump"):
			player_basic_movement.jump()
			
		if Input.is_action_just_pressed("sprint"):
			# Cannot sprint while dribbling
			if not Input.is_action_pressed("dribble"):
				player_basic_movement.start_sprinting()
		
		if Input.is_action_just_released("sprint"):
			player_basic_movement.end_sprinting()
