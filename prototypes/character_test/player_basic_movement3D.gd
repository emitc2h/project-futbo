class_name PlayerBasicMovement3D
extends Node3D

# Nodes controlled by this node
@export var player: Player3D
var asset: CharacterAsset

# Internal references
@onready var state: StateChart = $State
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var raycast: RayCast3D = $RayCast3D


# Movement configurable properties
var stamina_limit: float # in secs
var stamina_replenish_rate: float = 0.666

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
var fall_velocity_x: float
var previous_velocity_y: float

# The direction faced is independent from where the player is going. It does
# determine among other things, the maximum velocity as the player goes slower
# facing backward than forward.
var direction_faced: Enums.Direction

# State tracking
var in_run_state: bool = false
var in_sprint_state: bool = false
var in_idle_state: bool = false
var in_run_buffer_state: bool = false
var in_in_the_air_state: bool = false

# other tracking
var sprint_button_pressed: bool = false
var in_recovering_state: bool = false
var jump_set_to_fall: bool = false

# path constraint
var _path: CharacterPath = null
var _stay_on_path_force: float = 50.0
var player_velocity_callable: Callable = Callable(self, "_velocity_on_x_axis")
var player_float_callable: Callable = Callable(self, "_velocity_on_x_axis")


func _enter_tree() -> void:
	Signals.kicked.connect(_turn_left_interrupted)
	Signals.kicked.connect(_turn_right_interrupted)
	Signals.turn_left_animation_ended.connect(_turn_left_interrupted)
	Signals.turn_right_animation_ended.connect(_turn_right_interrupted)
	Signals.jump_left_animation_ended.connect(_on_jump_animation_ended)
	Signals.jump_right_animation_ended.connect(_on_jump_animation_ended)


func _ready() -> void:
	asset = player.asset
	stamina_limit = player.stamina_limit
	stamina_replenish_rate = player.stamina_replenish_rate
	stamina = stamina_limit
	
	run_deceleration = player.run_deceleration
	jump_momentum = player.jump_momentum
	
	raycast.target_position = Vector3.DOWN


func _physics_process(delta: float) -> void:
	# ALWAYS read input if on ground
	pass


# movement reusable functions
#----------------------------------------
func is_running_forward() -> bool:
	# If the player faces in the opposite direction that they're running,
	# those quantities will cancel out
	return (sign(left_right_axis) + direction_faced) != 0.0


func move_process(delta: float) -> void:
	asset.speed = lerp(asset.speed, left_right_axis, 0.4)
	player_velocity_callable.call(asset.root_motion_position.x/delta)


func fall_process(delta: float) -> void:
	player.velocity.y += gravity * delta
	player_velocity_callable.call(fall_velocity_x)


func in_the_air_process(delta: float, transition_to: String) -> void:
	if player.is_on_floor():
		in_in_the_air_state = false
		state.send_event(transition_to)
	else:
		fall_process(delta)
	
	# Needs to be called in every movement state
	player.move_and_slide()

#=======================================================
# MOVEMENT STATES
#=======================================================

# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	in_idle_state = true
	asset.to_idle()


func _on_idle_state_physics_processing(delta: float) -> void:
	move_process(delta)
	
	# If the floor falls from under the player
	if not player.is_on_floor():
		asset.to_fall()
		state.send_event("idle to fall")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_idle_state_exited() -> void:
	in_idle_state = false
	fall_velocity_x = player.velocity.x


# run state
#----------------------------------------
func _on_run_state_entered() -> void:
	print("RUN STATE ENTERED")
	in_run_state = true
	asset.to_move()
	
	# Start sprinting immediately if sprint button is already pressed
	# upon entering the run state
	if sprint_button_pressed and not in_recovering_state:
		state.send_event("run to sprint")


func _on_run_state_physics_processing(delta: float) -> void:
	move_process(delta)
	
	# Running off a ledge transitions to in the air state
	if not player.is_on_floor():
		asset.to_fall()
		state.send_event("run to fall")
	
	# Releasing the control while on the floor goes to idle
	if left_right_axis == 0.0:
		state.send_event("run to idle")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_run_state_exited() -> void:
	print("RUN STATE EXITED")
	in_run_state = false
	fall_velocity_x = player.velocity.x


# skid state
#----------------------------------------
func _on_skid_state_entered() -> void:
	asset.turn_to_move_path()
	print("SKID STATE ENTERED")


func _on_skid_state_physics_processing(delta: float) -> void:
	move_process(delta)
	
	# Running off a ledge transitions to in the air state
	if not player.is_on_floor():
		print("FALLING FROM THE EXPECTED PLACE")
		asset.turn_to_fall_path()
		state.send_event("skid to fall")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_skid_state_exited() -> void:
	print("SKID STATE EXITED")
	fall_velocity_x = player.velocity.x


func _on_skid_to_jump_taken() -> void:
	state.send_event("turn right to face right")
	state.send_event("turn left to face left")
	asset.to_jump()


# run buffer state
# Offers a brief time window when starting to run for the player to
# change direction without skidding
#----------------------------------------
func _on_run_buffer_state_entered() -> void:
	print("RUN BUFFER STATE ENTERED")
	in_run_buffer_state = true
	state.send_event("run buffer to run")
	if left_right_axis < 0.0:
		asset.face_left()
		asset.to_move_left()
	elif left_right_axis > 0.0:
		asset.face_right()
		asset.to_move_right()


func _on_run_buffer_state_physics_processing(delta: float) -> void:
	move_process(delta)
	
	# Running off a ledge transitions to fall state
	if not player.is_on_floor():
		asset.to_fall()
		state.send_event("run buffer to fall")
	
	# Releasing the control while on the floor goes to idle
	if left_right_axis == 0.0:
		state.send_event("run buffer to idle")
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_run_buffer_state_exited() -> void:
	print("RUN BUFFER STATE EXITED")
	in_run_buffer_state = false
	fall_velocity_x = player.velocity.x


# jump state
#----------------------------------------
func _on_jump_state_entered() -> void:
	print("JUMP STATE ENTERED")
	in_in_the_air_state = true
	player.velocity.y = jump_momentum
	fall_velocity_x = player.velocity.x * asset.jump_speed_factor
	print(asset.jump_speed_factor)
	asset.to_jump()
	state.send_event("jump to in the air")


func _on_jump_state_physics_processing(delta: float) -> void:
	move_process(delta)
	fall_process(delta)
	player.move_and_slide()


# in the air state
#----------------------------------------
func _on_in_the_air_state_entered() -> void:
	print("IN TNE AIR STATE ENTERED")
	in_in_the_air_state = true
	asset.jump_to_move_path()
	jump_set_to_fall = false
	previous_velocity_y = player.velocity.y


func _on_in_the_air_state_physics_processing(delta: float) -> void:
	in_the_air_process(delta, "in the air to run")
	# If it detects the ground, make sure the animation doesn't transition
	# to the fall animation
	if not raycast.is_colliding():
		if not jump_set_to_fall:
			asset.jump_to_fall_path()
			jump_set_to_fall = true
	previous_velocity_y = player.velocity.y


func _on_in_the_air_state_exited() -> void:
	print("IN THE AIR STATE EXITED")


func _on_jump_animation_ended() ->void:
	if player.is_on_floor():
		state.send_event("in the air to run")
	else:
		state.send_event("in the air to fall")


# jump buffer state
#----------------------------------------
func _on_jump_buffer_state_entered() -> void:
	print("JUMP BUFFER STATE ENTERED")
	jump_buffer_timer.start()


func _on_jump_buffer_state_physics_processing(delta: float) -> void:
	in_the_air_process(delta, "jump buffer to jump")


func _on_jump_buffer_timer_timeout() -> void:
	state.send_event("jump buffer to in the air")


func _on_jump_buffer_state_exited() -> void:
	print("JUMP BUFFER STATE EXITED")
	jump_buffer_timer.stop()



# fall state
#----------------------------------------
func _on_fall_state_entered() -> void:
	print("FALL STATE ENTERED")
	in_in_the_air_state = true


func _on_fall_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		in_in_the_air_state = false
		state.send_event("fall to run")
	else:
		player.velocity.y += gravity * delta
		player.velocity.x = fall_velocity_x
	
	# Needs to be called in every movement state
	player.move_and_slide()


func _on_fall_state_exited() -> void:
	asset.reset_jump_paths()
	asset.reset_turn_paths()
	print("FALL STATE EXITED")


#=======================================================
# DIRECTION STATES
#=======================================================

# face right state
#----------------------------------------
func _on_face_right_state_entered() -> void:
	direction_faced = Enums.Direction.RIGHT
	asset.face_right()
	Signals.facing_right.emit()


func _on_face_right_state_physics_processing(delta: float) -> void:
	if left_right_axis < 0.0 and not in_in_the_air_state \
		and not player.can_run_backward:
		if in_run_buffer_state or in_recovering_state:
			state.send_event("face right to face left")
			asset.face_left()
			asset.to_move_left()
		else:
			state.send_event("face right to turn left")
			asset.to_turn_right()


# face left state
#----------------------------------------
func _on_face_left_state_entered() -> void:
	direction_faced = Enums.Direction.LEFT
	asset.face_left()
	Signals.facing_left.emit()


func _on_face_left_state_physics_processing(delta: float) -> void:
	if left_right_axis > 0.0 and not in_in_the_air_state \
		and not player.can_run_backward:
		if in_run_buffer_state or in_recovering_state:
			state.send_event("face left to face right")
			asset.face_right()
			asset.to_move_right()
		else:
			state.send_event("face left to turn right")
			asset.to_turn_left()


# turn right state
#----------------------------------------
func _on_turn_right_state_entered() -> void:
	print("TURN RIGHT STATE ENTERED")
	asset.face_right()
	Signals.facing_right.emit()
	state.send_event("run to skid")


func _on_turn_right_state_physics_processing(delta: float) -> void:
	if not player.is_on_floor():
		state.send_event("turn right to face right")


func _on_turn_right_state_exited() -> void:
	print("TURN RIGHT STATE EXITED")
	state.send_event("skid to run")


func _turn_left_interrupted() -> void:
	state.send_event("turn right to face right")
	


# turn left state
#----------------------------------------
func _on_turn_left_state_entered() -> void:
	print("TURN LEFT STATE ENTERED")
	asset.face_left()
	Signals.facing_left.emit()
	state.send_event("run to skid")


func _on_turn_left_state_physics_processing(delta: float) -> void:
	if not player.is_on_floor():
		state.send_event("turn left to face left")


func _on_turn_left_state_exited() -> void:
	print("TURN LEFT STATE EXITED")
	state.send_event("skid to run")


func _turn_right_interrupted() -> void:
	state.send_event("turn left to face left")


#=======================================================
# STAMINA STATES
#=======================================================

# full state
#----------------------------------------
func _on_full_state_entered() -> void:
	print("FULL STATE ENTERED")
	asset.reset_speed()
	Signals.hide_stamina.emit()
	

# draining state
#----------------------------------------
func _on_draining_state_entered() -> void:
	print("DRAINING STATE ENTERED")
	asset.to_sprint()
	Signals.display_stamina.emit(Color.YELLOW)


func _on_draining_state_physics_processing(delta: float) -> void:
	stamina -= delta
	if stamina < 0:
		stamina = 0
		state.send_event("draining to recovering")
	Signals.update_stamina_value.emit(stamina/stamina_limit)


func _on_draining_state_exited() -> void:
	print("DRAINING STATE EXITED")
	pass


# replenishing state
#----------------------------------------
func _on_replenishing_state_entered() -> void:
	print("REPLENISHING STATE ENTERED")
	asset.reset_speed()
	Signals.display_stamina.emit(Color.GREEN)


func refill_stamina(delta: float) -> void:
	stamina += delta * stamina_replenish_rate
	if stamina > stamina_limit:
		stamina = stamina_limit
		state.send_event("replenishing to full")
		state.send_event("recovering to full")
	Signals.update_stamina_value.emit(stamina/stamina_limit)


func _on_replenishing_state_physics_processing(delta: float) -> void:
	refill_stamina(delta)


# recovering state
#----------------------------------------
func _on_recovering_state_entered() -> void:
	print("RECOVERING STATE ENTERED")
	in_recovering_state = true
	asset.to_recovery()
	Signals.display_stamina.emit(Color.DARK_RED)


func _on_recovering_state_physics_processing(delta: float) -> void:
	refill_stamina(delta)


func _on_recovering_state_exited() -> void:
	print("RECOVERING STATE EXITED")
	in_recovering_state = false
	asset.reset_speed()


#=======================================================
# CONSTRAINT STATES
#=======================================================

# x-axis state
#----------------------------------------
func _on_xaxis_state_entered() -> void:
	# Constrain movement along the x-axis
	player.axis_lock_linear_z = true
	player.axis_lock_angular_y = true
	
	# Apply velocity from input to x-axis only
	player_velocity_callable = Callable(self, "_velocity_on_x_axis")
	player_float_callable = Callable(self, "_velocity_on_x_axis")


# path state
#----------------------------------------
func _on_path_state_entered() -> void:
	# Unconstrain movement
	player.axis_lock_linear_z = false
	player.axis_lock_angular_y = false
	
	# Apply velocity from input along the path
	player_velocity_callable = Callable(self, "_velocity_on_path")
	player_float_callable = Callable(self, "_float_on_path")


#=======================================================
# CONTROL FUNCTIONS
#=======================================================

# stops the player from moving
func stop() -> void:
	left_right_axis = 0.0


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
		in_sprint_state = true
		state.send_event("full to draining")
		state.send_event("replenishing to draining")
		Signals.started_sprinting.emit()


func end_sprinting() -> void:
	sprint_button_pressed = false
	in_sprint_state = false
	state.send_event("draining to replenishing")
	fall_velocity_x = player.velocity.x
	Signals.ended_sprinting.emit()
	

# is meant to be call on button press
func jump() -> void:
	if player.is_on_floor():
		state.send_event("idle to jump")
		state.send_event("run to jump")
		state.send_event("run buffer to jump")
		state.send_event("skid to jump")
	else:
		state.send_event("in the air to jump buffer")
		state.send_event("fall to jump buffer")


func idle_with_custom_animation(animation: String) -> void:
	state.send_event("run to idle")


func get_on_path(path: CharacterPath) -> void:
	_path = path
	state.send_event("x-axis to path")


func get_off_path() -> void:
	state.send_event("path to x-axis")
	_path = null


#=======================================================
# UTILITY FUNCTIONS
#=======================================================
func _velocity_on_x_axis(input_magnitude: float) -> void:
	player.velocity.x = input_magnitude


func _velocity_on_path(input_magnitude: float) -> void:
	var offset: float = _path.curve.get_closest_offset(player.position)
	var closest_point: Vector3 = _path.curve.get_closest_point(player.position)
	var curve_transform: Transform3D = _path.curve.sample_baked_with_rotation(offset)
	var direction: Vector3 = curve_transform.basis.z
	
	player.rotation.y = Vector3(-1,0,0).signed_angle_to(direction, Vector3(0,1,0))
	
	if direction:
		var stay_on_path_correction: Vector3 = (closest_point - player.position)
		player.velocity.x = -input_magnitude * direction.x + _stay_on_path_force * stay_on_path_correction.x
		player.velocity.z = -input_magnitude * direction.z + _stay_on_path_force * stay_on_path_correction.z


func _float_on_path() -> void:
	var offset: float = _path.curve.get_closest_offset(player.position)
	var curve_transform: Transform3D = _path.curve.sample_baked_with_rotation(offset)
	var direction: Vector3 = curve_transform.basis.z
	
	player.rotation.y = Vector3(-1,0,0).signed_angle_to(direction, Vector3(0,1,0))
	
	var velocity_along_path_vec := Vector3(player.velocity.x, 0.0, player.velocity.z)
	var velocity_sign: float = sign(direction.dot(velocity_along_path_vec))
	
	var velocity_along_path: float = velocity_along_path_vec.length()
	
	if direction:
		player.velocity.x = velocity_sign * velocity_along_path * direction.x
		player.velocity.z = velocity_sign * velocity_along_path * direction.z


func _on_jump_state_exited() -> void:
	print("JUMP STATE EXITED")
