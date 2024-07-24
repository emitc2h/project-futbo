class_name Ball
extends Node

const KICK_FORCE: float = 700.0
const HEADBUTT_FORCE: float = 1000.0
const DRIBBLE_ROTATION_SPEED = 6.0
const DRIBBLE_AMPLITUDE = 15.0
const DRIBBLE_FREQUENCY = 8.0

var player_dribble_marker_position: Vector2

var dribble_time: float

var player_direction_faced: float
var player_velocity_x: float

var aim: Vector2
var clamped_aim_angle: float
var clamped_aim_vector: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

enum Mode {RIGID_MODE, CHAR_MODE}

var mode: Mode = Mode.RIGID_MODE


func _physics_process(delta: float) -> void:
	#print("aim: ", aim, "clamped_aim_angle: ", clamped_aim_angle)
	pass


func sync_transform_from_rigid_to_char() -> void:
	$CharNode.transform = $RigidNode.transform


func sync_transform_from_char_to_rigid() -> void:
	$RigidNode.transform = $CharNode.transform
	
	
func move_nodes_to_char() -> void:
	$RigidNode/DirectionRay.reparent($CharNode)
	$RigidNode/AnimatedSprite2D.reparent($CharNode)
	
func move_nodes_to_rigid() -> void:
	$CharNode/DirectionRay.reparent($RigidNode)
	$CharNode/AnimatedSprite2D.reparent($RigidNode)
	
	
func set_mode(input_mode: Mode) -> void:
	if input_mode == Mode.RIGID_MODE:
		sync_transform_from_char_to_rigid()
		move_nodes_to_rigid()
		$RigidNode.set_freeze_enabled(false)
		
	elif input_mode == Mode.CHAR_MODE:
		$RigidNode.set_freeze_enabled(true)
		sync_transform_from_rigid_to_char()
		move_nodes_to_char()
		
	self.mode = input_mode


func get_direction_ray() -> Sprite2D:
	if self.mode == Mode.RIGID_MODE:
		return $RigidNode/DirectionRay
	elif self.mode == Mode.CHAR_MODE:
		return $CharNode/DirectionRay
	else:
		return null


func get_animated_sprite_2d() -> AnimatedSprite2D:
	if self.mode == Mode.RIGID_MODE:
		return $RigidNode/AnimatedSprite2D
	elif self.mode == Mode.CHAR_MODE:
		return $CharNode/AnimatedSprite2D
	else:
		return null


func clamp_aim_angle(angle: float) -> float:
	if angle > 0.0:
		return PI/2
	else:
		return -PI/2


func _on_face_right_state_entered() -> void:
	if mode == Mode.CHAR_MODE:
		$CharNode.global_position = player_dribble_marker_position


func _on_face_right_state_physics_processing(delta: float) -> void:
	var raw_angle: float = aim.angle()
	if abs(raw_angle) > PI/2:
		clamped_aim_angle = clamp_aim_angle(raw_angle)
	else:
		clamped_aim_angle = raw_angle


func _on_face_left_state_entered() -> void:
	if mode == Mode.CHAR_MODE:
		$CharNode.global_position = player_dribble_marker_position


func _on_face_left_state_physics_processing(delta: float) -> void:
	var raw_angle: float = aim.angle()
	if abs(raw_angle) < PI/2:
		clamped_aim_angle = clamp_aim_angle(raw_angle)
	else:
		clamped_aim_angle = raw_angle


func _on_kickable_state_entered() -> void:
	get_animated_sprite_2d().modulate = Color.GREEN


func _on_kickable_state_exited() -> void:
	get_animated_sprite_2d().modulate = Color.WHITE
	
	
func _on_dribbled_state_entered() -> void:
	self.set_mode(Mode.CHAR_MODE)
	$CharNode.global_position = player_dribble_marker_position
	dribble_time = 0.0


func _on_dribbled_state_physics_processing(delta: float) -> void:
	dribble_time += delta
	$CharNode.velocity.x = player_velocity_x
	if not $CharNode.is_on_floor():
		$CharNode.velocity.y += gravity * delta
	$CharNode.move_and_slide()
	$CharNode.rotation += player_direction_faced * DRIBBLE_ROTATION_SPEED * delta * PI


func _on_dribbled_state_exited() -> void:
	self.set_mode(Mode.RIGID_MODE)


func _on_kick_state_entered() -> void:
	var force: Vector2 = KICK_FORCE * clamped_aim_vector.normalized()
	$RigidNode.apply_central_impulse(force)
	$StateChart.send_event("kick_to_not_kickable")


func _on_headbutt_state_entered() -> void:
	$RigidNode.apply_central_impulse(HEADBUTT_FORCE * Vector2.UP + Vector2(player_velocity_x, 0.0))
	$StateChart.send_event("headbutt_to_no_headbutt")


func _on_idle_state_entered() -> void:
	get_direction_ray().visible = false


func _on_idle_state_physics_processing(delta: float) -> void:
	clamped_aim_vector = Vector2(player_direction_faced, 0)
	get_direction_ray().global_rotation = clamped_aim_vector.angle() + PI/2


func _on_pointing_state_entered() -> void:
	get_direction_ray().visible = true


func _on_pointing_state_physics_processing(delta: float) -> void:
	clamped_aim_vector = Vector2.from_angle(clamped_aim_angle)
	get_direction_ray().global_rotation = clamped_aim_angle + PI/2
