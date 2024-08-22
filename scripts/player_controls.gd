class_name ControllerPlayer
extends Node2D

################################################
# A file that maps inputs to state transitions #
################################################

@export var player: Player
@onready var player_state: StateChart = player.get_node("StateChart")

var ball: Ball
var ball_state: StateChart

var ball_is_kickable: bool = false
var is_ready_to_dribble: bool = false
var is_dribbling: bool = false
var previous_direction: float = 0.0
var previous_aim: Vector2 = Vector2.ZERO

enum DirectionFaced {LEFT, RIGHT}
var direction_faced: DirectionFaced

signal clamped_aim_angle(angle: float)
signal send_ball_state(transition: String)
signal player_direction_faced(direction: float)

signal kick(kick_vector: Vector2)


func clamp_aim_angle(angle: float) -> float:
	if angle > 0.0:
		return PI/2
	else:
		return -PI/2


func aim_angle_face_right(aim_vector: Vector2) -> float:
	var raw_angle: float = aim_vector.angle()
	if abs(raw_angle) > PI/2:
		return clamp_aim_angle(raw_angle)
	else:
		return raw_angle


func aim_angle_face_left(aim_vector: Vector2) -> float:
	var raw_angle: float = aim_vector.angle()
	if abs(raw_angle) < PI/2:
		return clamp_aim_angle(raw_angle)
	else:
		return raw_angle


func compute_clamped_aim_angle(aim_vector: Vector2, direction: DirectionFaced) -> float:
	if direction == DirectionFaced.LEFT:
		if aim_vector.is_zero_approx():
			return Vector2.LEFT.angle()
		else:
			return aim_angle_face_left(aim_vector)
	else:
		if aim_vector.is_zero_approx():
			return Vector2.RIGHT.angle()
		else:
			return aim_angle_face_right(aim_vector)


func _physics_process(delta: float) -> void:
	var direction: float = Input.get_axis("move_left", "move_right")
	player.direction = direction
	
	if direction != 0.0:
		player_state.send_event("idle_to_running")
	
	var aim: Vector2 = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if not aim.is_zero_approx():
		send_ball_state.emit("idle_to_pointing")
		
	player.direction_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Detect press and releases on joystick axes 
	var is_direction_just_pressed: bool = previous_direction == 0 and direction != 0
	var is_direction_just_released: bool = previous_direction != 0.0 and direction == 0.0
	var is_aim_just_released: bool = not previous_aim.is_zero_approx() and aim.is_zero_approx()
		
	previous_direction = direction
	previous_aim = aim
	
	if is_direction_just_pressed:
		player_state.send_event("pre_idle_to_running")
	
	if is_direction_just_released:
		player_state.send_event("running_to_pre_idle")
	
	if is_aim_just_released:
		send_ball_state.emit("pointing_to_idle")
	
	
	# If the player is dribbling, the direction the player faces is controlled
	# with the right joystick
	if is_dribbling:
		if Input.is_action_just_pressed("aim_left"):
			player_state.send_event("right_to_left")
			direction_faced = DirectionFaced.LEFT
			player_direction_faced.emit(-1.0)
			
		if Input.is_action_just_pressed("aim_right"):
			player_state.send_event("left_to_right")
			direction_faced = DirectionFaced.RIGHT
			player_direction_faced.emit(1.0)
	
	
	# The moving direction is independent from where the player faces when dribbling
	# When the player is not dribbling, movement and direction faced are synced.
	if not is_dribbling:
		if Input.is_action_just_pressed("move_left"):
			player_state.send_event("face_right_to_turn_left")
			direction_faced = DirectionFaced.LEFT
			player_direction_faced.emit(-1.0)
		
		if Input.is_action_just_pressed("move_right"):
			player_state.send_event("face_left_to_turn_right")
			direction_faced = DirectionFaced.RIGHT
			player_direction_faced.emit(1.0)
		
	if Input.is_action_just_pressed("jump"):
		player_state.send_event("idle_to_jump")
		player_state.send_event("running_to_jump")
	
	var aim_angle: float = compute_clamped_aim_angle(aim, direction_faced)
	clamped_aim_angle.emit(aim_angle)
	
	if Input.is_action_just_pressed("kick"):
		if ball_is_kickable or is_dribbling:
			kick.emit(Vector2.from_angle(aim_angle))
			if is_dribbling:
				player_state.send_event("dribble_to_kick")
			else:
				player_state.send_event("can_kick_to_kick")

		
	if Input.is_action_just_pressed("dribble"):
		is_ready_to_dribble = true
		player_state.send_event("cannot_kick_to_ready_to_dribble")
		if ball and ball.mode == ball.Mode.RIGID_MODE and ball_is_kickable:
			player_state.send_event("can_kick_to_dribble")
			ball_state.send_event("inert_to_dribbled")
		
	if Input.is_action_just_released("dribble"):
		is_ready_to_dribble = false
		# You can cause other players to drop the ball just by releasing the button
		if ball_state:
			ball_state.send_event("dribbled_to_inert")
		player_state.send_event("dribble_to_can_kick")
		player_state.send_event("ready_to_dribble_to_cannot_kick")


func _on_player_velocity_x(vx: float) -> void:
	ball.player_velocity_x = vx


func _on_player_entered_kickzone(ball_ref: Ball) -> void:
	ball = ball_ref
	ball_state = ball.get_node("StateChart")
	player_state.send_event("ready_to_dribble_to_dribble")
	if is_ready_to_dribble:
		ball_state.send_event("inert_to_dribbled")
			
	ball_is_kickable = true
	ball.get_animated_sprite_2d().modulate = Color.GREEN


func _on_player_left_kickzone(ball_ref: Ball) -> void:
	ball_is_kickable = false
	ball_ref.get_animated_sprite_2d().modulate = Color.WHITE
	if not is_dribbling:
		ball = null
		ball_state = null


func _on_player_did_headbutt() -> void:
	ball_state.send_event("no_headbutt_to_headbutt")


func _on_player_did_jump(vy: float) -> void:
	ball.jump(vy)


func _on_player_started_dribbling() -> void:
	is_dribbling = true


func _on_player_ended_dribbling() -> void:
	is_dribbling = false
	ball = null
	ball_state = null


func _on_player_player_velocity(v: Vector2) -> void:
	ball.player_velocity = v


func _on_player_lost_ball() -> void:
	ball_state.send_event("dribbled_to_inert")
	ball = null
	ball_state = null
