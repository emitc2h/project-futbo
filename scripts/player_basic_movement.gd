class_name PlayerBasicMovement
extends Node

# Nodes controlled by this node
@export var player: Player2
var sprite: AnimatedSprite2D

# Internal references
@onready var state: StateChart = $State
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var turn_right_timer: Timer = $TurnRightTimer
@onready var turn_left_timer: Timer = $TurnLeftTimer

# Movement configurable properties
@export var run_forward_velocity: float
@export var run_backward_velocity: float
@export var run_deceleration: float
@export var jump_momentum: float

# Static/Internal properties
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Dynamic properties
# A real value from -1.0 to 1.0, -1.0 corresponding to moving left,
# 1.0 to moving right. It controls how fast w.r.t. to the max velocity
# the player is running.
var left_right_axis: float

# The direction faced is independent from where the player is going. It does
# determine among other things, the maximum velocity as the player goes slower
# facing backward than forward.
var direction_faced: Enums.Direction

# Track the time left in turning state for skidding
var turning_time_left: float = 0.0

# State tracking
var in_run_state: bool = false
var in_idle_state: bool = false
var in_run_buffer_state: bool = false
var in_in_the_air_state: bool = false

# Signals
signal facing_left()
signal facing_right()


func _ready() -> void:
	sprite = player.sprite


#=======================================================
# MOVEMENT STATES
#=======================================================

# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	in_idle_state = true
	sprite.play("idle")


func _on_idle_state_physics_processing(delta: float) -> void:
	# Instead of stopping abruptly, decelerate
	player.velocity.x = move_toward(player.velocity.x, 0, run_deceleration)
	
	# If the floor falls from under the player
	if not player.is_on_floor():
		sprite.play("fall")
		state.send_event("idle to in the air")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_idle_state_exited() -> void:
	in_idle_state = false


# run state
#----------------------------------------
func is_running_forward() -> bool:
	# If the player faces in the opposite direction that they're running,
	# those quantities will cancel out
	return (sign(left_right_axis) + direction_faced) != 0.0


func run_process() -> void:
	# Determine the maximum velocity
	var max_velocity: float = run_backward_velocity
	if is_running_forward():
		max_velocity = run_forward_velocity
	
	# Apply the velocity to the player
	player.velocity.x = left_right_axis * max_velocity


func _on_run_state_entered() -> void:
	in_run_state = true
	sprite.play("run")


func _on_run_state_physics_processing(delta: float) -> void:
	run_process()
	
	# Running off a ledge transitions to in the air state
	if not player.is_on_floor():
		sprite.play("fall")
		state.send_event("run to in the air")
	
	# Releasing the control while on the floor goes to idle
	if left_right_axis == 0.0:
		state.send_event("run to idle")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_run_state_exited() -> void:
	in_run_state = false


# skid state
#----------------------------------------
func skid_process() -> void:
		# when turning, slow down and accelerate in the opposite direction
	# turning_time_left should go from 2.0 to 0.0 over the course of the timer
	if turning_time_left > 0.0:
		player.velocity.x *= (1.0 - turning_time_left)


func _on_skid_state_entered() -> void:
	sprite.play("skid")


func _on_skid_state_physics_processing(delta: float) -> void:
	run_process()
	skid_process()
	
	# Skidding off a ledge transitions to in the air state
	if not player.is_on_floor():
		sprite.play("fall")
		state.send_event("skid to in the air")
	
	# Needs to be called in every movement state
	player.move_and_slide()



# run buffer state
# Offers a brief time window when starting to run for the player to
# change direction without skidding
#----------------------------------------
func _on_run_buffer_state_entered() -> void:
	in_run_buffer_state = true
	state.send_event("run buffer to run")
	sprite.play("run")


func _on_run_buffer_state_physics_processing(delta: float) -> void:
	run_process()
	
	# Running off a ledge transitions to in the air state
	if not player.is_on_floor():
		sprite.play("fall")
		state.send_event("run buffer to in the air")
	
	# Releasing the control while on the floor goes to idle
	if left_right_axis == 0.0:
		state.send_event("run buffer to idle")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_run_buffer_state_exited() -> void:
	in_run_buffer_state = false


# jump state
#----------------------------------------
func _on_jump_state_entered() -> void:
	run_process()
	player.velocity.y = jump_momentum
	state.send_event("jump to in the air")
	sprite.play("jump")


func _on_jump_state_physics_processing(delta: float) -> void:
	# Extend the run process into the first 50 milliseconds of the jump so
	# it's easier to jump sideways when idle
	run_process()
	
	# Needs to be called in every movement state
	player.move_and_slide()


# in the air state
#----------------------------------------
func _on_in_the_air_state_entered() -> void:
	in_in_the_air_state = true


func _on_in_the_air_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		state.send_event("in the air to run")
	else:
		player.velocity.y += gravity * delta
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_in_the_air_state_exited() -> void:
	in_in_the_air_state = false


# jump buffer state
#----------------------------------------
func _on_jump_buffer_state_entered() -> void:
	jump_buffer_timer.start()


func _on_jump_buffer_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		state.send_event("jump buffer to jump")
	else:
		player.velocity.y += gravity * delta
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_jump_buffer_timer_timeout() -> void:
	state.send_event("jump buffer to in the air")


func _on_jump_buffer_state_exited() -> void:
	jump_buffer_timer.stop()


#=======================================================
# DIRECTION STATES
#=======================================================

# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	direction_faced = Enums.Direction.RIGHT
	sprite.flip_h = false
	facing_right.emit()


func _on_face_right_state_physics_processing(delta: float) -> void:
	if left_right_axis < 0.0 and not in_in_the_air_state \
		and not player.can_run_backward:
			
		if in_run_buffer_state:
			state.send_event("face right to face left")
		else:
			state.send_event("run to skid")
			state.send_event("face right to turn left")


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	direction_faced = Enums.Direction.LEFT
	sprite.flip_h = true
	facing_left.emit()


func _on_face_left_state_physics_processing(delta: float) -> void:
	if left_right_axis > 0.0 and not in_in_the_air_state \
		and not player.can_run_backward:
		if in_run_buffer_state:
			state.send_event("face left to face right")
		else:
			state.send_event("run to skid")
			state.send_event("face left to turn right")


# turn right state
#----------------------------------------
func _on_turn_right_state_entered() -> void:
	turn_right_timer.start()
	turning_time_left = 2.0
	direction_faced = Enums.Direction.RIGHT


func _on_turn_right_state_physics_processing(delta: float) -> void:
	if in_in_the_air_state:
		state.send_event("turn right to face right")
	turning_time_left = 2 * turn_right_timer.time_left / turn_right_timer.wait_time


func _on_turn_right_timer_timeout() -> void:
	state.send_event("turn right to face right")
	state.send_event("skid to run")


func _on_turn_right_state_exited() -> void:
	turn_right_timer.stop()
	turning_time_left = 0.0


# turn left state
#----------------------------------------
func _on_turn_left_state_entered() -> void:
	turn_left_timer.start()
	turning_time_left = 2.0
	direction_faced = Enums.Direction.LEFT


func _on_turn_left_state_physics_processing(delta: float) -> void:
	if in_in_the_air_state:
		state.send_event("turn left to face left")
	turning_time_left = 2 * turn_left_timer.time_left / turn_left_timer.wait_time


func _on_turn_left_timer_timeout() -> void:
	state.send_event("turn left to face left")
	state.send_event("skid to run")


func _on_turn_left_state_exited() -> void:
	turn_left_timer.stop()
	turning_time_left = 0.0


#=======================================================
# CONTROL FUNCTIONS
#=======================================================

# is meant to be called every frame (joystick non-zero input)
func run(direction: float) -> void:
	left_right_axis = direction
	if abs(left_right_axis) > 0.01:
		# This logic isn't functionally necessary, but it cleans up the state
		# history
		if in_idle_state:
			state.send_event("idle to run buffer")


# is meant to be call on button press
func jump() -> void:
	if player.is_on_floor():
		state.send_event("idle to jump")
		state.send_event("run to jump")
		state.send_event("skid to jump")
		state.send_event("run buffer to jump")
	else:
		state.send_event("in the air to jump buffer")

