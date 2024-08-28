class_name PlayerBasicMovement
extends Node

# Nodes controlled by this node
@export var body: CharacterBody2D
@export var sprite: AnimatedSprite2D

# Internal references
@onready var state: StateChart = $State
@onready var idle_buffer_timer: Timer = $IdleBufferTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

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
enum DirectionFaced {LEFT = -1, RIGHT = 1}
var direction_faced: DirectionFaced

# Track the time left in turning state for skidding
var turning_time_left: float = 0.0


#=======================================================
# MOVEMENT STATES
#=======================================================

# 1. idle state
#----------------------------------------
func _on_idle_state_physics_processing(delta: float) -> void:
	# Instead of stopping abruptly, decelerate
	body.velocity.x = move_toward(body.velocity.x, 0, run_deceleration)
	
	# If the floor falls from under the player
	if not body.is_on_floor():
		state.send_event("idle to in the air")


# 2. run state
#----------------------------------------
func run(direction: float) -> void:
	left_right_axis = direction
	state.send_event("idle to run")
	state.send_event("idle buffer to run")

func is_running_forward() -> bool:
	# If the player faces in the opposite direction that they're running,
	# those quantities will cancel out
	return (sign(left_right_axis) + direction_faced) != 0.0


func run_process() -> void:
	# Determine the maximum velocity
	var max_velocity: float = run_backward_velocity
	if is_running_forward():
		max_velocity = run_forward_velocity
	
	# Apply the velocity to the body
	body.velocity.x = left_right_axis * max_velocity
	
	# when turning, slow down and accelerate in the opposite direction
	# turning_time_left should go from 2.0 to 0.0 over the course of the timer
	if turning_time_left > 0.0:
		body.velocity.x *= (1.0 - turning_time_left)

func _on_run_state_physics_processing(delta: float) -> void:
	run_process()
	
	# Running off a ledge transitions to in the air state
	if not body.is_on_floor():
		state.send_event("running to in the air")


# 3. idle buffer state
#----------------------------------------
func _on_idle_buffer_state_entered() -> void:
	idle_buffer_timer.start()


func _on_idle_buffer_state_physics_processing(delta: float) -> void:
	run_process()
	
	# Get back to running state if input is received
	if abs(left_right_axis) > 0.0:
		state.send_event("idle buffer to run")
	
	# Running off a ledge transitions to in the air state
	if not body.is_on_floor():
		state.send_event("idle buffer to in the air")


func _on_idle_buffer_timeout() -> void:
	state.send_event("idle buffer to idle")


func _on_idle_buffer_state_exited() -> void:
	idle_buffer_timer.stop()


# 4. jump state
#----------------------------------------
func jump() -> void:
	if body.is_on_floor():
		state.send_event("idle to jump")
		state.send_event("run to jump")
		state.send_event("idle buffer to jump")
	else:
		state.send_event("in the air to jump buffer")


func _on_jump_state_entered() -> void:
	body.velocity.y = jump_momentum
	state.send_event("jump to in the air")


func _on_jump_state_physics_processing(delta: float) -> void:
	# Extend the run process into the first 50 milliseconds of the jump so
	# it's easier to jump sideways when idle
	run_process()


# 5. in the air state
#----------------------------------------
func _on_in_the_air_state_physics_processing(delta: float) -> void:
	if body.is_on_floor():
		state.send_event("in the air to run")
	else:
		body.velocity.y += gravity * delta


# 6. jump buffer state
#----------------------------------------
func _on_jump_buffer_state_entered() -> void:
	jump_buffer_timer.start()


func _on_jump_buffer_state_physics_processing(delta: float) -> void:
	if body.is_on_floor():
		state.send_event("jump buffer to jump")
	else:
		body.velocity.y += gravity * delta


func _on_jump_buffer_timer_timeout() -> void:
	state.send_event("jump buffer to in the air")


func _on_jump_buffer_state_exited() -> void:
	jump_buffer_timer.stop()
