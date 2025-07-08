class_name Drone
extends Node3D

enum Mode {RIGID, CHAR, RAGDOLL, DEAD}
var mode: Mode = Mode.CHAR

const FACE_RIGHT_Y_ROT = Vector3(0.0, PI/2, 0.0)
const FACE_LEFT_Y_ROT = Vector3(0.0, -PI/2, 0.0)

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")
var float_cast_length: float = 1.8
var time_floating: float = 0.0

var initial_position: Vector3 = Vector3(0,0,0)
var direction: Enums.Direction = Enums.Direction.LEFT
var target: Node3D

var bone_transforms: Array[Transform3D] = []

# Internal references
@onready var state: StateChart = $State

@onready var char_node: CharacterBody3D = $CharNode
@onready var rigid_node: RigidBody3D = $RigidNode

@onready var model: Node3D = $DroneModel
@onready var model_mesh: MeshInstance3D = $DroneModel/Armature/Skeleton3D/drone

@onready var carry_along_container: Node3D = $CarryAlongContainer
@onready var float_cast: RayCast3D = $CarryAlongContainer/FloatCast
@onready var float_distortion_mesh: MeshInstance3D = $CarryAlongContainer/Distortion
@onready var float_distortion_material: ShaderMaterial = float_distortion_mesh.get_surface_override_material(0)

@onready var field_of_view: FieldOfView = $DroneModel/FieldOfView

@onready var model_anim_tree: AnimationTree = $DroneModel/AnimationTree
@onready var anim_state: AnimationNodeStateMachinePlayback
@onready var exhaust_material: ShaderMaterial = model_mesh.get_surface_override_material(6)

@onready var bone_simulation: PhysicalBoneSimulator3D = $DroneModel/Armature/Skeleton3D/PhysicalBoneSimulator3D
@onready var skeleton: Skeleton3D = $DroneModel/Armature/Skeleton3D

@onready var closed_collision_shape_char: CollisionShape3D = $CharNode/ClosedCollisionShape3D
@onready var open_collision_shape_char: CollisionShape3D = $CharNode/OpenCollisionShape3D
@onready var closed_collision_shape_rigid: CollisionShape3D = $RigidNode/ClosedCollisionShape3D

@onready var proximity_detector: Area3D = $DroneModel/ProximityDetector

@onready var patrol_marker_1: Marker3D = $PatrolMarker1
@onready var patrol_marker_2: Marker3D = $PatrolMarker2

@onready var target_none_timer: Timer = $TargetNoneTimer
@onready var target_loss_timer: Timer = $TargetLossTimer
@onready var dead_timer: Timer = $DeadTimer
@onready var quick_closing_timer: Timer = $QuickClosingTimer
@onready var burst_timer: Timer = $BurstTimer
@onready var attack_burst_timer: Timer = $AttackBurstTimer

# State tracking
var in_rigid_state: bool = false
var in_closed_state: bool = true
var in_open_state: bool = true
var in_turn_state: bool = false
var targeting_enabled: bool = true
var tracking_target: bool = false
var target_acquired: bool = false
var in_burst_state: bool = false
var in_thrust_state: bool = false

# Tweeners
var turn_tween: Tween

# Handles
@export_group("Animation Handles")
@export var left_right_axis: float = 0.0

@export_group("Movement parameters")
@export var float_speed: float = 3.0
@export var thrust_speed: float = 5.0
@export var burst_speed: float = 12.0

@export_group("Sight parameters")


var sees_player: bool:
	get:
		if targeting_enabled:
			var drone_sees_player: bool = field_of_view.sees_player
			if drone_sees_player:
				target = field_of_view.target
				state.send_event("none to acquired")
			return drone_sees_player
		return false


func _ready() -> void:
	initial_position = char_node.global_position
	model_anim_tree.animation_finished.connect(_on_model_animation_finished)
	rigid_node.max_speed = 10.0
	bone_simulation.active = true
	anim_state = model_anim_tree.get("parameters/playback")


#=======================================================
# MODE STATES
#=======================================================

const distortion_mesh_intensity_off: float = 0.0
const distortion_mesh_intensity_on: float = 1.0
const distortion_on_duration: float = 1.0
const distortion_off_duration: float = 0.5

# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	# reset time floating
	time_floating = 0.0

	# Disable rigid node collisions
	closed_collision_shape_rigid.disabled = true
	
	# Enable char node collisions
	if in_closed_state:
		closed_collision_shape_char.disabled = false
	else:
		open_collision_shape_char.disabled = false

	# Put the rigid node to sleep
	rigid_node.set_freeze_enabled(true)
	rigid_node.can_sleep = true
	rigid_node.sleeping = true
	
	# char node takes ownership of transform
	char_node.transform = rigid_node.transform
	
	# Set mode
	mode = Mode.CHAR
	
	# Turn on float distortion
	print("turning on distortion")
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(float_distortion_material, "shader_parameter/noise_intensity", distortion_mesh_intensity_on, distortion_on_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(distortion_mesh_intensity_off)
	
	
func _on_char_state_physics_processing(delta: float) -> void:
	
	#increment time floating
	time_floating += delta
	
	# Gravity is always on in char mode
	if not char_node.is_on_floor():
		char_node.velocity.y += gravity * delta
	
	if float_cast.is_colliding():
		# Detect the ground and push against the ground
		var lift_factor: float = 1.0 - (abs(float_cast.get_collision_point().y - float_cast.global_position.y) / float_cast_length)**2
		char_node.velocity.y += -gravity * 4.0 * lift_factor * delta
		
		# dampen the oscillation
		char_node.velocity.y -= 4.0 * char_node.velocity.y * delta
		
		# little bit of a floating animation
		char_node.velocity.y -= 0.015 * sin( 3.0 * time_floating )
	
	# Apply horizontal speed
	var speed: float = float_speed
	if in_burst_state:
		speed = burst_speed
	if in_thrust_state:
		speed = thrust_speed
	char_node.velocity.x = lerp(char_node.velocity.x, left_right_axis * speed, 4.0 * delta)
	
	char_node.move_and_slide()
	
	# Force drone to look in the right direction
	if not (in_turn_state):
		var target_direction: Vector3 = FACE_LEFT_Y_ROT
		if direction == Enums.Direction.RIGHT:
			target_direction = FACE_RIGHT_Y_ROT
		
		if target and target_acquired:
			var pointer_to_target: Vector3 = char_node.global_position - target.global_position - Vector3.UP * 1.5
			self.char_node.rotation.x = min(asin(abs(pointer_to_target.y) / pointer_to_target.length()), 0.4)
		
		var target_orientation: Quaternion = Quaternion.from_euler(target_direction)
		var current_orientation: Quaternion = Quaternion.from_euler(char_node.rotation)
		var new_orientation: Quaternion = current_orientation.slerp(target_orientation, 0.1)
		char_node.rotation = new_orientation.get_euler()
	
	# model, float cast, float distortion follow char node
	model.transform = char_node.transform
	carry_along_container.position = char_node.position
	
	# rigid node follows char node
	rigid_node.transform = char_node.transform
	rigid_node.linear_velocity = char_node.velocity


func _on_char_state_exited() -> void:
	# Turn off float distortion
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(float_distortion_material, "shader_parameter/noise_intensity", distortion_mesh_intensity_off, distortion_off_duration)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(distortion_mesh_intensity_on)


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
	in_rigid_state = true
	# wake up the rigid node
	rigid_node.set_freeze_enabled(false)
	rigid_node.can_sleep = false
	rigid_node.sleeping = false
	
	# rigid node takes ownership of transform
	rigid_node.set_transform_and_velocity(char_node.global_transform, char_node.velocity)
	char_node.velocity = Vector3.ZERO
	
	# Enable rigid node collisions
	closed_collision_shape_rigid.disabled = false
	
	# Disable char node collisions
	closed_collision_shape_char.disabled = true
	open_collision_shape_char.disabled = true
	
	# Set mode
	mode = Mode.RIGID


func _on_rigid_state_physics_processing(delta: float) -> void:
	# model, float cast and float distortion follow rigid node
	model.transform = rigid_node.transform
	carry_along_container.position = rigid_node.position
	
	# char node follows rigid node
	char_node.transform = rigid_node.transform


func _on_rigid_state_exited() -> void:
	in_rigid_state = false


# ragdoll state
#----------------------------------------
func _on_ragdoll_state_entered() -> void:
	# Set mode
	mode = Mode.RAGDOLL
	
	# disable all other collision shapes
	closed_collision_shape_rigid.queue_free()
	closed_collision_shape_char.queue_free()
	open_collision_shape_char.queue_free()
	
	# Disable animations
	model_anim_tree.active = false
	
	# Disable float cast
	proximity_detector.queue_free()
	
	# Start the ragdoll simulation
	bone_simulation.physical_bones_start_simulation()

	# turn off the field of view
	field_of_view.enabled = false
	
	#timer to dead state
	dead_timer.start()
	
	# This is temporary until I have a better disappearing animation
	await get_tree().create_timer(5).timeout
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(model_mesh, "transparency", 1.0, 5.0)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_LINEAR)\
		.from(0.0)


func _on_dead_timer_timeout() -> void:
	dead_timer.stop()
	state.send_event("ragdoll to dead")


func _on_ragdoll_state_exited() -> void:
	# Stop the ragdoll simulation
	bone_simulation.physical_bones_stop_simulation()


# dead state
#----------------------------------------
func _on_dead_state_entered() -> void:
	mode = Mode.DEAD
	self.queue_free()


#=======================================================
# ENGAGEMENT STATES
#=======================================================

# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	if mode == Mode.RIGID:
		closed_collision_shape_rigid.disabled = false
	elif mode == Mode.CHAR:
		closed_collision_shape_char.disabled = false


func _on_open_to_closing_taken() -> void:
	anim_state.travel("close up")


func _on_open_to_quick_closing_taken() -> void:
	anim_state.travel("quick close")


func _on_open_to_quick_closing_from_thrust_taken() -> void:
	anim_state.travel("thrust close")


# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	float_distortion_mesh.position.y = -1.0
	in_closed_state = true
	if mode == Mode.CHAR:
		open_collision_shape_char.disabled = true


func _on_closed_state_exited() -> void:
	in_closed_state = false


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	if tracking_target:
		anim_state.travel("targeting")
	else:
		anim_state.travel("idle")
	if mode == Mode.CHAR:
		open_collision_shape_char.disabled = false


# opening state
#----------------------------------------
func _on_open_state_entered() -> void:
	float_distortion_mesh.position.y = -1.2
	in_open_state = true
	if mode == Mode.CHAR:
		closed_collision_shape_char.disabled = true


func _on_open_state_exited() -> void:
	in_open_state = false


# quick closing state
#----------------------------------------
func _on_quick_closing_state_entered() -> void:
	quick_closing_timer.stop()
	in_closed_state = true


func _on_quick_closing_timer_timeout() -> void:
	quick_closing_timer.stop()
	state.send_event("quick closing to closed")


#=======================================================
# DIRECTION STATES
#=======================================================

# face left state
#----------------------------------------
func _on_turn_left_entered() -> void:
	direction = Enums.Direction.LEFT
	in_turn_state = true
	if turn_tween:
		turn_tween.kill()
	turn_tween = get_tree().create_tween()
	turn_tween.tween_property(char_node, "rotation", Vector3.ZERO, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(char_node.rotation)
	turn_tween.tween_property(char_node, "rotation", FACE_LEFT_Y_ROT, 1.0)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3.ZERO)
	await turn_tween.finished
	state.send_event("turn left to face left")


func _on_turn_left_state_exited() -> void:
	in_turn_state = false


# face right state
#----------------------------------------
func _on_turn_right_entered() -> void:
	direction = Enums.Direction.RIGHT
	in_turn_state = true
	if turn_tween:
		turn_tween.kill()
	turn_tween = get_tree().create_tween()
	turn_tween.tween_property(char_node, "rotation", Vector3.ZERO, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(char_node.rotation)
	turn_tween.tween_property(char_node, "rotation", FACE_RIGHT_Y_ROT, 1.0)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3.ZERO)
	await turn_tween.finished
	state.send_event("turn right to face right")


func _on_turn_right_state_exited() -> void:
	in_turn_state = false


#=======================================================
# TARGET STATES
#=======================================================
const target_none_range: float = 4.0
const target_none_focus: float = 1.0

const target_acquired_range: float = 10.0
const target_acquired_focus: float = 8.0

const target_lost_range: float = 8.0
const target_lost_focus: float = 4.0


# target none state
#----------------------------------------
func _on_none_state_entered() -> void:
	field_of_view.range = target_none_range
	field_of_view.focus = target_none_focus


func _on_target_none_timer_timeout() -> void:
	target_none_timer.stop()
	if not (in_burst_state or in_thrust_state):
		self.close()


# target acquired state
#----------------------------------------
func _on_acquired_state_entered() -> void:
	target_none_timer.stop()
	target_loss_timer.stop()
	tracking_target = true
	target_acquired = true
	self.stop_thrust()
	self.stop_burst()
	self.open()
	anim_state.travel("targeting")
	field_of_view.range = target_acquired_range
	field_of_view.focus = target_acquired_focus
	Signals.update_zoom.emit(Enums.Zoom.FAR)


func _on_acquired_state_physics_processing(delta: float) -> void:
	if not field_of_view.sees_player:
		state.send_event("acquired to lost")
	if in_closed_state:
		await get_tree().create_timer(1.0).timeout
		state.send_event("closed to opening")


func _on_acquired_state_exited() -> void:
	target_acquired = false


# target lost state
#----------------------------------------
func _on_lost_state_entered() -> void:
	anim_state.travel("idle")
	target_loss_timer.start()
	field_of_view.range = target_lost_range
	field_of_view.focus = target_lost_focus


func _on_lost_state_physics_processing(delta: float) -> void:
	self.sees_player
	if in_closed_state:
		await get_tree().create_timer(1.0).timeout
		state.send_event("closed to opening")


func _on_target_lost_to_none_taken() -> void:
	target_none_timer.start()
	Signals.update_zoom.emit(Enums.Zoom.FAR)


func _on_target_loss_timer_timeout() -> void:
	target_loss_timer.stop()
	tracking_target = false
	state.send_event("lost to none")


#=======================================================
# ENGINE STATES
#=======================================================
const off_noise_intensity: float = 0.0
const off_noise_speed: float = 0.0

const thrust_noise_intensity: float = 15.0
const thrust_noise_speed: float = 2.0

const burst_noise_intensity: float = 100.0
const burst_noise_speed: float = 3.0

enum AfterBurst { OFF = 0, THRUST = 1 }
var after_burst_state: AfterBurst = AfterBurst.OFF


func _tween_engines(
	noise_speed: float,
	noise_intensity_from: float,
	noise_intensity_to: float,
	ease: Tween.EaseType,
	trans: Tween.TransitionType,
	duration: float) -> Tween:
		var tween: Tween = get_tree().create_tween()
		exhaust_material.set_shader_parameter("noise_speed", noise_speed)
		tween.tween_property(exhaust_material, "shader_parameter/noise_intensity", noise_intensity_to, duration)\
			.set_ease(ease)\
			.set_trans(trans)\
			.from(noise_intensity_from)
		return tween


# readying burst state
#----------------------------------------
func _on_readying_burst_state_entered() -> void:
	if not in_open_state:
		self.open()
	else:
		state.send_event("readying to burst")


func _on_readying_to_burst_taken() -> void:
	anim_state.travel("idle thrust")
	_tween_engines(
		burst_noise_speed,
		off_noise_intensity, burst_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_BACK,
		0.4)


# burst state
#----------------------------------------
func _on_burst_state_entered() -> void:
	anim_state.travel("idle thrust")
	in_burst_state = true


func _on_burst_state_exited() -> void:
	in_burst_state = false


func _on_burst_to_off_taken() -> void:
	if tracking_target:
		anim_state.travel("targeting")
	else:
		self.close()
	_tween_engines(
		off_noise_speed,
		burst_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.8)


func _on_burst_to_quick_close_off_taken() -> void:
	state.send_event("open to quick closing from thrust")
	_tween_engines(
		off_noise_speed,
		burst_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.1)


func _on_burst_to_thrust_taken() -> void:
	_tween_engines(
		thrust_noise_speed,
		burst_noise_intensity, thrust_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_LINEAR,
		0.6)


func _on_burst_timer_timeout() -> void:
	burst_timer.stop()
	if after_burst_state == AfterBurst.THRUST:
		state.send_event("burst to thrust")
	else:
		state.send_event("burst to off")


# readying thrust state
#----------------------------------------
func _on_readying_thrust_state_entered() -> void:
	if not in_open_state:
		self.open()
	else:
		state.send_event("readying to thrust")


func _on_readying_to_thrust_taken() -> void:
	_tween_engines(
		thrust_noise_speed,
		off_noise_intensity, thrust_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_BACK,
		0.6)


# thrust state
#----------------------------------------
func _on_thrust_state_entered() -> void:
	anim_state.travel("idle thrust")
	in_thrust_state = true


func _on_thrust_state_exited() -> void:
	if tracking_target:
		anim_state.travel("targeting")
	else:
		anim_state.travel("idle")
	in_thrust_state = false


func _on_thrust_to_off_taken() -> void:
	_tween_engines(
		off_noise_speed,
		thrust_noise_intensity, off_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_QUART,
		0.8)


func _on_thrust_to_burst_taken() -> void:
	_tween_engines(
		burst_noise_speed,
		thrust_noise_intensity, burst_noise_intensity,
		Tween.EASE_OUT,
		Tween.TRANS_LINEAR,
		0.6)

#=======================================================
# SIGNALS RECEIVED
#=======================================================

func _on_model_animation_finished(anim_name: StringName) -> void:
	if anim_name == "OpenUp":
		state.send_event("opening to open")
		state.send_event("readying to thrust")
		state.send_event("readying to burst")
	if anim_name == "CloseUp":
		state.send_event("closing to closed")
	if anim_name == "QuickClose" or anim_name == "ThrustClose":
		state.send_event("quick closing to closed")


func _on_proximity_detector_body_entered(body: Node3D) -> void:
	quick_close()



#=======================================================
# CONTROL FUNCTIONS
#=======================================================

func open() -> void:
	state.send_event("closed to opening")
	state.send_event("closing to opening")


func close() -> void:
	state.send_event("open to closing")


func quick_close() -> void:
	state.send_event("open to quick closing")
	state.send_event("opening to quick closing")
	state.send_event("closing to quick closing")
	quick_closing_timer.start()


func become_inert() -> void:
	state.send_event("char to rigid")
	disable_targeting()


func start_floating() -> void:
	state.send_event("rigid to char")
	enable_targeting()


func become_ragdoll() -> void:
	state.send_event("rigid to ragdoll")
	state.send_event("char to ragdoll")
	disable_targeting()


func disable_targeting() -> void:
	targeting_enabled = false
	state.send_event("target none to disabled")
	state.send_event("target acquired to disabled")
	state.send_event("target lost to disabled")
	target_none_timer.stop()
	target_loss_timer.stop()


func enable_targeting() -> void:
	targeting_enabled = true
	state.send_event("target disabled to none")


func face_left() -> void:
	state.send_event("face right to turn left")
	state.send_event("turn right to turn left")


func face_right() -> void:
	state.send_event("face left to turn right")
	state.send_event("turn left to turn right")


func move_toward_x_pos(target_x: float, delta: float, away: bool = false) -> void:
	var direction: float = 1.0
	if away:
		direction = -1.0
	var target_value: float = direction * (target_x - get_mode_position().x) / max(abs(target_x - get_mode_position().x), 0.5)
	left_right_axis = lerp(left_right_axis, target_value, 20.0 * delta)


func move_toward_target(delta: float) -> void:
	if target:
		move_toward_x_pos(self.target.global_position.x, delta)


func stop_moving(delta: float) -> void:
	left_right_axis = lerp(left_right_axis, 0.0, 10.0 * delta)


func burst(duration: float, after_burst_state: AfterBurst) -> void:
	burst_timer.start()
	self.after_burst_state = after_burst_state
	state.send_event("off to readying burst")
	state.send_event("thrust to burst")


func stop_burst() -> void:
	burst_timer.stop()
	state.send_event("burst to off")


func ram_attack() -> void:
	attack_burst_timer.start()
	state.send_event("off to readying burst")
	state.send_event("thrust to burst")


func _on_attack_burst_timer_timeout() -> void:
	attack_burst_timer.stop()
	state.send_event("burst to quick close off")
	self.become_inert()


func thrust() -> void:
	state.send_event("off to readying thrust")
	state.send_event("burst to thrust")


func stop_thrust() -> void:
	state.send_event("thrust to off")


func get_hit(strength: float) -> bool:
	print("STRENGTH: ", strength)
	if strength > 5 and not in_closed_state:
		self.become_ragdoll()
		return true
	return false


#=======================================================
# UTIL FUNCTIONS
#=======================================================
func get_mode_position() -> Vector3:
	if mode == Mode.RIGID:
		return rigid_node.global_position
	elif mode == Mode.CHAR:
		return char_node.global_position
	else:
		return model.global_position
