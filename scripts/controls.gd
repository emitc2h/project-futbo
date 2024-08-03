extends Node2D

################################################
# A file that maps inputs to state transitions #
################################################

@export var player: Player
@export var ball: Ball

@onready var player_state: StateChart = player.get_node("StateChart")
@onready var ball_state: StateChart = ball.get_node("StateChart")

var is_dribbling: bool = false
var previous_direction: float = 0.0
var previous_aim: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
		
	var direction: float = Input.get_axis("move_left", "move_right")
	player.direction = direction
	
	if abs(direction) > 0.0:
		player_state.send_event("idle_to_running")
		ball.player_velocity_x = player.velocity.x
		
	var aim: Vector2 = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if not aim.is_zero_approx():
		ball_state.send_event("idle_to_pointing")
		ball.aim = aim
		
	# Is direction pressed
	if previous_direction == 0 and direction != 0:
		player_state.send_event("pre_idle_to_running")
	
	# Is direction released
	if previous_direction != 0.0 and direction == 0.0:
		player_state.send_event("running_to_pre_idle")
	
	# Is aim released
	if not previous_aim.is_zero_approx() and aim.is_zero_approx():
		ball_state.send_event("pointing_to_idle")


	# If the player is dribbling, the direction the player faces is controlled
	# with the right joystick
	if is_dribbling:
		if Input.is_action_just_pressed("aim_left"):
			player_state.send_event("face_right_to_turn_left")
			ball_state.send_event("right_to_left")
			
		if Input.is_action_just_pressed("aim_right"):
			player_state.send_event("face_left_to_turn_right")
			ball_state.send_event("left_to_right")


	# The moving direction is independent from where the player faces when dribbling
	# When the player is not dribbling, movement and direction faced are synced.
	if not is_dribbling:
		if Input.is_action_just_pressed("move_left"):
			player_state.send_event("face_right_to_turn_left")
			ball_state.send_event("right_to_left")
			ball.player_direction_faced = -1.0
		
		if Input.is_action_just_pressed("move_right"):
			player_state.send_event("face_left_to_turn_right")
			ball_state.send_event("left_to_right")
			ball.player_direction_faced = 1.0
		
	if Input.is_action_just_pressed("jump"):
		player_state.send_event("idle_to_jump")
		player_state.send_event("running_to_jump")
		
	if Input.is_action_just_pressed("kick"):
		player_state.send_event("can_kick_to_kick")
		player_state.send_event("dribble_to_kick")
		ball_state.send_event("kickable_to_kick")
		ball_state.send_event("dribbled_to_kick")
		
	if Input.is_action_just_pressed("dribble"):
		player_state.send_event("can_kick_to_dribble")
		player_state.send_event("cannot_kick_to_ready_to_dribble")
		ball_state.send_event("kickable_to_dribbled")
		ball_state.send_event("not_kickable_to_dribble_ready")
		
	if Input.is_action_just_released("dribble"):
		player_state.send_event("dribble_to_can_kick")
		player_state.send_event("ready_to_dribble_to_cannot_kick")
		ball_state.send_event("dribbled_to_kickable")
		ball_state.send_event("dribble_ready_to_not_kickable")
		
	previous_direction = direction
	previous_aim = aim


## Signal processing between siblings
func _on_player_ball_state_chart_event(event: String) -> void:
	ball_state.send_event(event)


func _on_player_velocity_x(vx: float) -> void:
	ball.player_velocity_x = vx


func _on_player_dribble_marker_position(pos: Vector2) -> void:
	ball.player_dribble_marker_position = pos


func _on_player_entered_kickzone() -> void:
	player_state.send_event("ready_to_dribble_to_dribble")
	ball_state.send_event("dribble_ready_to_dribbled")
	ball_state.send_event("not_kickable_to_kickable")


func _on_player_left_kickzone() -> void:
	ball_state.send_event("kickable_to_not_kickable")


func _on_player_did_headbutt() -> void:
	ball_state.send_event("no_headbutt_to_headbutt")


func _on_player_did_jump(vy: float) -> void:
	ball.jump(vy)


func _on_player_started_dribbling() -> void:
	is_dribbling = true


func _on_player_ended_dribbling() -> void:
	is_dribbling = false


func _on_turn_left_timer_timeout() -> void:
	player_state.send_event("turn_left_to_face_left")


func _on_turn_right_timer_timeout() -> void:
	player_state.send_event("turn_right_to_face_right")


func _on_player_player_velocity(v: Vector2) -> void:
	ball.player_velocity = v
