class_name PlayerController
extends Node

@export var character: CharacterBase

@export_group("Parameters")
@export var idle_buffer_time: float = 0.05

var left_right_axis_is_zero_time_elapsed: float = 0.0


func _ready() -> void:
	Signals.player_takes_damage.connect(character.damage_states.take_damage)
	## Make it known to the character that they are the player,  so they can send player-specific signals
	character.is_player = true


func _physics_process(delta: float) -> void:
	## GROUNDED MOVEMENT CONTROLS
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
	
	## Jumping
	if Input.is_action_just_pressed("jump"):
		character.jump()
		if character.dribble_states.state == character.dribble_states.State.DRIBBLING:
			pass
	
	## BALL CONTROLS
	## ------------------------------------
	
	## Kicking
	if Input.is_action_just_pressed("kick"):
		print("kick button pressed")
		character.kick()
		character.kick_states.engage_long_kick_intent()
	
	if Input.is_action_just_released("kick"):
		character.kick_states.disengage_long_kick_intent()
	
	## Dribbling
	if Input.is_action_just_pressed("dribble"):
		character.dribble()
		character.dribble_states.engage_dribble_intent()
	
	if Input.is_action_just_released("dribble"):
		character.dribble_states.disengage_dribble_intent()
	
	if character.dribble_states.state == character.dribble_states.State.NO_BALL:
		if Input.is_action_just_pressed("warp"):
			Signals.player_requests_warp.emit()
