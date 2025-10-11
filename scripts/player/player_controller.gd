class_name PlayerController
extends Node

@export var character: CharacterBase

@export_group("Parameters")
@export var idle_buffer_time: float = 0.05

var left_right_axis_is_zero_time_elapsed: float = 0.0


func _physics_process(delta: float) -> void:
	
	## GROUNDED MOVEMENT
	## ------------------------------------
	
	## Read in the left_right_axis from the controller
	var left_right_axis: float = Input.get_axis("move_left", "move_right")
	var aim_vector: Vector2 = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	
	## When the player is dribbling the ball, switch the control of what direction is faced to the aim vector
	if Input.is_action_just_pressed("dribble"):
		character.lock_direction_faced()
	
	if Input.is_action_just_released("dribble"):
		character.unlock_direction_faced(left_right_axis)
	
	if character.direction_states.locked:
		if not aim_vector.is_zero_approx():
			if aim_vector.x < 0.0:
				character.face_left()
			if aim_vector.x > 0.0:
				character.face_right()
	
	## If the left_right_axis doesn't read 0 (which means the joystick is out of the dead zone)
	if abs(left_right_axis) > 0.0:
		## Put character in move mode
		character.move(left_right_axis)
		## Reset idle timer to 0
		left_right_axis_is_zero_time_elapsed = 0.0
	else:
		## Increment idle timer
		left_right_axis_is_zero_time_elapsed += delta

	## If the idle timer accrues enough time, transition to idle state
	if left_right_axis_is_zero_time_elapsed > idle_buffer_time:
		character.idle()
	
	if Input.is_action_just_pressed("jump"):
		character.jump()
	
	if Input.is_action_just_pressed("kick"):
		character.kick()
		character.kick_states.engage_long_kick_intent()
	
	if Input.is_action_just_released("kick"):
		character.kick_states.disengage_long_kick_intent()
