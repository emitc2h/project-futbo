class_name PlayerBasicMovement
extends Node

# Nodes controlled by this node
@export var player: Player
var sprite: AnimatedSprite3D

# Internal references
@onready var state: StateChart = $State
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var turn_right_timer: Timer = $TurnRightTimer
@onready var turn_left_timer: Timer = $TurnLeftTimer

# Movement configurable properties
var sprint_velocity: float
var recovery_velocity: float
var stamina_limit: float # in secs
var stamina_replenish_rate: float = 0.666

var run_forward_velocity: float
var run_backward_velocity: float
var run_deceleration: float
var jump_momentum: float

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

# Dynamic properties
# A real value from -1.0 to 1.0, -1.0 corresponding to moving left,
# 1.0 to moving right. It controls how fast w.r.t. to the max velocity
# the player is running.
var left_right_axis: float
var stamina: float

# The direction faced is independent from where the player is going. It does
# determine among other things, the maximum velocity as the player goes slower
# facing backward than forward.
var direction_faced: Enums.Direction

# Track the time left in turning state for skidding
var turning_time_left: float = 0.0

# animation overrides
const DEFAULT_JUMP_ANIMATION: String = "jump"
var jump_animation: String = DEFAULT_JUMP_ANIMATION

const DEFAULT_IDLE_ANIMATION: String = "idle"
var idle_animation: String = DEFAULT_IDLE_ANIMATION

# State tracking
var in_run_state: bool = false
var in_sprint_state: bool = false
var in_idle_state: bool = false
var in_run_buffer_state: bool = false
var in_in_the_air_state: bool = false

# other tracking
var sprint_button_pressed: bool = false
var in_recovering_state: bool = false

# Signals
signal facing_left()
signal facing_right()

signal display_stamina(color: Color)
signal hide_stamina()
signal update_stamina_value(value: float)

signal started_sprinting()
signal ended_sprinting()


func _ready() -> void:
	sprite = player.sprite
	sprint_velocity = player.sprint_velocity
	stamina_limit = player.stamina_limit
	stamina_replenish_rate = player.stamina_replenish_rate
	stamina = stamina_limit
	
	recovery_velocity = player.recovery_velocity
	run_forward_velocity = player.run_forward_velocity
	run_backward_velocity = player.run_backward_velocity
	run_deceleration = player.run_deceleration
	jump_momentum = player.jump_momentum


#=======================================================
# MOVEMENT STATES
#=======================================================

# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	in_idle_state = true
	sprite.play(idle_animation)


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
	idle_animation = DEFAULT_IDLE_ANIMATION


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
	if in_sprint_state:
		max_velocity = sprint_velocity
	if in_recovering_state:
		max_velocity = recovery_velocity
	
	# Apply the velocity to the player
	player.velocity.x = left_right_axis * max_velocity


func _on_run_state_entered() -> void:
	in_run_state = true
	sprite.play("run")
	
	# Start sprinting immediately if sprint button is already pressed
	# upon entering the run state
	if sprint_button_pressed and not in_recovering_state:
		state.send_event("run to sprint")


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


# sprint state
#----------------------------------------
func _on_sprint_state_entered() -> void:
	in_sprint_state = true
	state.send_event("full to draining")
	state.send_event("replenishing to draining")


func _on_sprint_state_physics_processing(delta: float) -> void:
	run_process()
	
	# Delegate both scenarios to the run state
	if (left_right_axis == 0.0) or (not player.is_on_floor()):
		state.send_event("sprint to run")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_sprint_state_exited() -> void:
	in_sprint_state = false
	state.send_event("draining to replenishing")


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
	sprite.play(jump_animation)


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
	# Reset jump animation
	jump_animation = DEFAULT_JUMP_ANIMATION


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
# STAMINA STATES
#=======================================================

# full state
#----------------------------------------
func _on_full_state_entered() -> void:
	hide_stamina.emit()
	

# draining state
#----------------------------------------
func _on_draining_state_entered() -> void:
	display_stamina.emit(Color.YELLOW)
	started_sprinting.emit()


func _on_draining_state_physics_processing(delta: float) -> void:
	stamina -= delta
	if stamina < 0:
		stamina = 0
		state.send_event("draining to recovering")
	update_stamina_value.emit(stamina/stamina_limit)


func refill_stamina(delta: float) -> void:
	stamina += delta * stamina_replenish_rate
	if stamina > stamina_limit:
		stamina = stamina_limit
		state.send_event("replenishing to full")
		state.send_event("recovering to full")
	update_stamina_value.emit(stamina/stamina_limit)


func _on_draining_state_exited() -> void:
	ended_sprinting.emit()


# replenishing state
#----------------------------------------
func _on_replenishing_state_entered() -> void:
	display_stamina.emit(Color.GREEN)



func _on_replenishing_state_physics_processing(delta: float) -> void:
	refill_stamina(delta)


# recovering state
#----------------------------------------
func _on_recovering_state_entered() -> void:
	in_recovering_state = true
	display_stamina.emit(Color.DARK_RED)


func _on_recovering_state_physics_processing(delta: float) -> void:
	refill_stamina(delta)


func _on_recovering_state_exited() -> void:
	in_recovering_state = false


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


func start_sprinting() -> void:
	sprint_button_pressed = true
	if not in_recovering_state:
		state.send_event("run to sprint")


func end_sprinting() -> void:
	sprint_button_pressed = false
	state.send_event("sprint to run")
	

# is meant to be call on button press
func jump() -> void:
	if player.is_on_floor():
		state.send_event("idle to jump")
		state.send_event("run to jump")
		state.send_event("skid to jump")
		state.send_event("run buffer to jump")
	else:
		state.send_event("in the air to jump buffer")


func jump_with_custom_animation(animation: String) -> void:
	jump_animation = animation
	jump()


func idle_with_custom_animation(animation: String) -> void:
	idle_animation = animation
	state.send_event("run to idle")
