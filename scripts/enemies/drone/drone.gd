class_name Drone
extends Node3D

enum Mode {RIGID, CHAR, RAGDOLL}
var mode: Mode = Mode.RIGID

const FACE_RIGHT_Y_ROT = Vector3(0.0, PI/2, 0.0)
const FACE_LEFT_Y_ROT = Vector3(0.0, -PI/2, 0.0)

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")
var float_cast_length: float = 2.0
var time_floating: float = 0.0

var initial_position: Vector3 = Vector3(0,0,0)
var direction: Enums.Direction = Enums.Direction.LEFT
var target: Node3D

# Internal references
@onready var state: StateChart = $State

@onready var char_node: CharacterBody3D = $CharNode
@onready var rigid_node: RigidBody3D = $RigidNode

@onready var model: Node3D = $DroneModel
@onready var float_cast: RayCast3D = $FloatCast
@onready var field_of_view: FieldOfView = $DroneModel/FieldOfView

@onready var model_animations: AnimationPlayer = $DroneModel/AnimationPlayer

@onready var bone_simulation: PhysicalBoneSimulator3D = $DroneModel/Armature/Skeleton3D/PhysicalBoneSimulator3D

@onready var closed_collision_shape_char: CollisionShape3D = $CharNode/ClosedCollisionShape3D
@onready var open_collision_shape_char: CollisionShape3D = $CharNode/OpenCollisionShape3D
@onready var closed_collision_shape_rigid: CollisionShape3D = $RigidNode/ClosedCollisionShape3D

@onready var patrol_marker_1: Marker3D = $PatrolMarker1
@onready var patrol_marker_2: Marker3D = $PatrolMarker2

@onready var target_loss_timer: Timer = $TargetLossTimer

# State tracking
var in_closed_state: bool = true
var in_turn_state: bool = false
var tracking_target: bool = false

# Signals
signal in_char_mode

# Handles
@export var left_right_axis: float = 0.0
@export var max_speed: float = 3.0

var sees_player: bool:
	get:
		var drone_sees_player: bool = field_of_view.sees_player
		if drone_sees_player:
			target = field_of_view.target
			state.send_event("none to acquired")
		return drone_sees_player

func _ready() -> void:
	initial_position = char_node.global_position
	model_animations.play("Closed")
	model_animations.animation_finished.connect(_on_model_animation_finished)
	rigid_node.max_speed = 10.0
	bone_simulation.active = true


#=======================================================
# MODE STATES
#=======================================================

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
	
	in_char_mode.emit()
	
	
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
	char_node.velocity.x = left_right_axis * max_speed
	
	char_node.move_and_slide()
	
	# Force drone to look in the right direction
	if not in_turn_state:
		var target_direction: Vector3 = FACE_LEFT_Y_ROT
		if direction == Enums.Direction.RIGHT:
			target_direction = FACE_RIGHT_Y_ROT
		
		var target_orientation: Quaternion = Quaternion.from_euler(target_direction)
		var current_orientation: Quaternion = Quaternion.from_euler(char_node.rotation)
		var new_orientation: Quaternion = current_orientation.slerp(target_orientation, 0.1)
		char_node.rotation = new_orientation.get_euler()
	
	# model and float cast follow char node
	model.transform = char_node.transform
	float_cast.position = char_node.position
	
	# rigid node follows char node
	rigid_node.transform = char_node.transform
	rigid_node.linear_velocity = char_node.velocity


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
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
	
	# model and float cast follow rigid node
	model.transform = rigid_node.transform
	float_cast.position = rigid_node.position
	
	# char node follows rigid node
	char_node.transform = rigid_node.transform


# ragdoll state
#----------------------------------------
func _on_ragdoll_state_entered() -> void:
	# Set mode
	mode = Mode.RAGDOLL
	
	# disable all other collision shapes
	closed_collision_shape_rigid.disabled = true
	closed_collision_shape_char.disabled = true
	open_collision_shape_char.disabled = true
	
	# Disable animations
	model_animations.active = false
	
	# Start the ragdoll simulation
	bone_simulation.physical_bones_start_simulation()
	# bone_simulation.active = true


func _on_ragdoll_state_exited() -> void:
	
	# Stop the ragdoll simulation
	bone_simulation.physical_bones_stop_simulation()
	# bone_simulation.active = false
	
		# re-enable animations
	model_animations.active = true


#=======================================================
# ENGAGEMENT STATES
#=======================================================

# closing state
#----------------------------------------
func _on_closing_state_entered() -> void:
	model_animations.play_backwards("OpenUp")
	if mode == Mode.RIGID:
		closed_collision_shape_rigid.disabled = false
	elif mode == Mode.CHAR:
		closed_collision_shape_char.disabled = false


# closed state
#----------------------------------------
func _on_closed_state_entered() -> void:
	in_closed_state = true
	if mode == Mode.CHAR:
		open_collision_shape_char.disabled = true
		


func _on_closed_state_exited() -> void:
	in_closed_state = false


# opening state
#----------------------------------------
func _on_opening_state_entered() -> void:
	model_animations.play("OpenUp")
	if mode == Mode.CHAR:
		open_collision_shape_char.disabled = false



# opening state
#----------------------------------------
func _on_open_state_entered() -> void:
	if mode == Mode.CHAR:
		closed_collision_shape_char.disabled = true


#=======================================================
# DIRECTION STATES
#=======================================================

# face left state
#----------------------------------------
func _on_turn_left_entered() -> void:
	direction = Enums.Direction.LEFT
	in_turn_state = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(char_node, "rotation", Vector3.ZERO, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(FACE_RIGHT_Y_ROT)
	tween.tween_property(char_node, "rotation", FACE_LEFT_Y_ROT, 1.0)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3.ZERO)
	await tween.finished
	state.send_event("turn left to face left")


func _on_turn_left_state_exited() -> void:
	in_turn_state = false


# face right state
#----------------------------------------
func _on_turn_right_entered() -> void:
	direction = Enums.Direction.RIGHT
	in_turn_state = true
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(char_node, "rotation", Vector3.ZERO, 0.5)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)\
		.from(FACE_LEFT_Y_ROT)
	tween.tween_property(char_node, "rotation", FACE_RIGHT_Y_ROT, 1.0)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)\
		.from(Vector3.ZERO)
	await tween.finished
	state.send_event("turn right to face right")


func _on_turn_right_state_exited() -> void:
	in_turn_state = false


#=======================================================
# TARGET STATES
#=======================================================

# target none state
#----------------------------------------
func _on_none_state_entered() -> void:
	self.close()
	field_of_view.range = 4.0
	

# target acquired state
#----------------------------------------
func _on_acquired_state_entered() -> void:
	self.open()
	tracking_target = true
	field_of_view.range = 8.0


func _on_acquired_state_physics_processing(delta: float) -> void:
	if not field_of_view.sees_player:
		state.send_event("acquired to lost")


# target lost state
#----------------------------------------
func _on_lost_state_entered() -> void:
	target_loss_timer.start()
	field_of_view.range = 6.0


func _on_lost_state_physics_processing(delta: float) -> void:
	if field_of_view.sees_player:
		state.send_event("lost to acquired")
		target_loss_timer.stop()


func _on_target_loss_timer_timeout() -> void:
	tracking_target = false
	state.send_event("lost to none")
	target = null


#=======================================================
# SIGNALS RECEIVED
#=======================================================

func _on_model_animation_finished(anim_name: StringName) -> void:
	if anim_name == "OpenUp":
		state.send_event("closing to closed")
		state.send_event("opening to open")

#=======================================================
# CONTROL FUNCTIONS
#=======================================================

func open() -> void:
	state.send_event("closed to opening")

func close() -> void:
	state.send_event("open to closing")

func become_inert() -> void:
	state.send_event("char to rigid")
	state.send_event("ragdoll to rigid")

func start_floating() -> void:
	state.send_event("rigid to char")
	state.send_event("ragdoll to char")

func become_ragdoll() -> void:
	state.send_event("rigid to ragdoll")
	state.send_event("char to ragdoll")

func face_left() -> void:
	state.send_event("face right to turn left")

func face_right() -> void:
	state.send_event("face left to turn right")
	
func move_toward_x_pos(target_x: float, delta: float) -> void:
	var target_value: float = (target_x - get_mode_position().x) / max(abs(target_x - get_mode_position().x), 0.5)
	left_right_axis = lerp(left_right_axis, target_value, 3.0 * delta)

func stop_moving(delta: float) -> void:
	left_right_axis = lerp(left_right_axis, 0.0, 3.0 * delta)


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
		
		
func reset_position() -> void:
	state.send_event("rigid to char")
	state.send_event("ragdoll to char")
	char_node.global_position = initial_position
	model_animations.play("Closed")
