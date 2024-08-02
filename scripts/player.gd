class_name Player
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kickzone_x: float = $KickZone/KickCollider.transform.origin.x
@onready var dribble_marker_x: float = $DribbleMarker.transform.origin.x

const RUN_FORWARD_VELOCITY = 500.0
const RUN_BACKWARD_VELOCITY = 300.00
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: float
var direction_faced: float = 1.0
var is_dribbling: bool = false
var is_playing_animation: bool = false
var turning_time_left: float = 0.0
var from_idle: bool = false

signal velocity_x(vx: float)
signal dribble_marker_position(pos: Vector2)
signal entered_kickzone()
signal left_kickzone()
signal did_headbutt()
signal did_jump(vy: float)
signal started_dribbling()
signal ended_dribbling()
signal player_velocity(v: Vector2)


func _physics_process(delta: float) -> void:
	print("Time Left: ", $TurnLeftTimer.time_left)
	move_and_slide()


func _on_kick_zone_body_entered(_body: Node2D) -> void:
	$StateChart.send_event("cannot_kick_to_can_kick")
	entered_kickzone.emit()


func _on_kick_zone_body_exited(_body: Node2D) -> void:
	$StateChart.send_event("can_kick_to_cannot_kick")
	left_kickzone.emit()
	
	
func _on_headbutt_zone_body_entered(_body: Node2D) -> void:
	$StateChart.send_event("can_headbutt_to_headbutt")


func running_state_base(run_velocity: float) -> void:
	velocity.x = direction * run_velocity
	if not (from_idle or is_dribbling):
		velocity.x *= (1.0 - turning_time_left)
	if not is_on_floor():
		$StateChart.send_event("running_to_in_the_air")


func is_running_forward() -> bool:
	return (sign(direction) + direction_faced) != 0.0


func _on_running_state_processing(_delta: float) -> void:
	if not is_playing_animation:
		animated_sprite.play("walk")


func _on_running_state_physics_processing(delta: float) -> void:
	if is_running_forward():
		running_state_base(RUN_FORWARD_VELOCITY)
	else:
		running_state_base(RUN_BACKWARD_VELOCITY)


func _on_running_state_exited() -> void:
	from_idle = false


func _on_idle_state_processing(_delta: float) -> void:
	if not is_playing_animation:
		animated_sprite.play("idle")


func _on_idle_state_physics_processing(delta: float) -> void:
	var run_velocity: float = RUN_FORWARD_VELOCITY
	velocity.x = move_toward(velocity.x, 0, run_velocity)


func _on_idle_state_exited() -> void:
	from_idle = true


func _on_kick_state_entered() -> void:
	player_velocity.emit(self.velocity)
	$StateChart.send_event("kick_to_cannot_kick")
	animated_sprite.play("kick")
	is_playing_animation = true


func _on_kick_state_exited() -> void:
	is_playing_animation = false


func _on_jump_state_entered() -> void:
	velocity.y = JUMP_VELOCITY
	did_jump.emit(JUMP_VELOCITY)
	$StateChart.send_event("jump_to_in_the_air")
	$StateChart.send_event("cannot_headbutt_to_can_headbutt")


func _on_jump_state_exited() -> void:
	from_idle = false


func _on_in_the_air_state_entered() -> void:
	animated_sprite.play("jump")
	is_playing_animation = true


func _on_in_the_air_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		$StateChart.send_event("in_the_air_to_idle")
		$StateChart.send_event("can_headbutt_to_cannot_headbutt")
	else:
		velocity.y += gravity * delta


func _on_in_the_air_state_exited() -> void:
	is_playing_animation = false


func _on_face_left_state_entered() -> void:
	$TurnLeftTimer.stop()
	animated_sprite.flip_h = true
	$KickZone/KickCollider.transform.origin.x = -kickzone_x
	direction_faced = -1.0
	$DribbleMarker.transform.origin.x = -dribble_marker_x


func _on_face_right_state_entered() -> void:
	$TurnRightTimer.stop()
	animated_sprite.flip_h = false
	$KickZone/KickCollider.transform.origin.x = kickzone_x
	direction_faced = 1.0
	$DribbleMarker.transform.origin.x = dribble_marker_x


func _on_turn_left_state_entered() -> void:
	$TurnLeftTimer.start()
	turning_time_left = 2.0
	is_playing_animation = true
	animated_sprite.play("turn")
	direction_faced = -1.0
	$DribbleMarker.transform.origin.x = -dribble_marker_x


func _on_turn_left_state_physics_processing(delta: float) -> void:
	turning_time_left = 2 * $TurnLeftTimer.time_left / $TurnLeftTimer.wait_time


func _on_turn_left_state_exited() -> void:
	turning_time_left = 0.0
	is_playing_animation = false
	from_idle = false


func _on_turn_right_state_entered() -> void:
	$TurnRightTimer.start()
	turning_time_left = 2.0
	is_playing_animation = true
	animated_sprite.play("turn")
	direction_faced = 1.0
	$DribbleMarker.transform.origin.x = dribble_marker_x
	
	
func _on_turn_right_state_physics_processing(delta: float) -> void:
	turning_time_left = 2 * $TurnRightTimer.time_left / $TurnRightTimer.wait_time


func _on_turn_right_state_exited() -> void:
	turning_time_left = 0.0
	is_playing_animation = false
	from_idle = false


func _on_headbutt_state_entered() -> void:
	velocity_x.emit(self.velocity.x)
	did_headbutt.emit()
	$StateChart.send_event("headbutt_to_cannot_headbutt")


func _on_dribble_state_physics_processing(delta: float) -> void:
	velocity_x.emit(self.velocity.x)
	dribble_marker_position.emit($DribbleMarker.global_position)


func _on_dribble_state_entered() -> void:
	is_dribbling = true
	started_dribbling.emit()


func _on_dribble_state_exited() -> void:
	is_dribbling = false
	player_velocity.emit(self.velocity)
	ended_dribbling.emit()


func _on_counting_down_state_entered() -> void:
	$IdleTimer.start()


func _on_not_moving_state_entered() -> void:
	$IdleTimer.stop()
	
	
func _on_idle_timer_timeout() -> void:
	$StateChart.send_event("running_to_idle")
	$StateChart.send_event("counting_down_to_not_moving")


func _on_moving_state_entered() -> void:
	$IdleTimer.stop()
