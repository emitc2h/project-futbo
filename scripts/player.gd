class_name Player
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var kickzone_x: float = $KickZone/KickCollider.transform.origin.x
@onready var dribble_marker_x: float = $DribbleMarker.transform.origin.x

const RUN_VELOCITY = 500.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var direction: float
var direction_faced: float = 1.0

signal velocity_x(vx: float)
signal dribble_marker_position(pos: Vector2)
signal entered_kickzone()
signal left_kickzone()
signal did_headbutt()
signal did_jump(vy: float)


func _physics_process(delta: float) -> void:
	move_and_slide()


func _on_kick_zone_body_entered(_body: Node2D) -> void:
	$StateChart.send_event("cannot_kick_to_can_kick")
	entered_kickzone.emit()


func _on_kick_zone_body_exited(_body: Node2D) -> void:
	$StateChart.send_event("can_kick_to_cannot_kick")
	left_kickzone.emit()
	
	
func _on_headbutt_zone_body_entered(_body: Node2D) -> void:
	$StateChart.send_event("can_headbutt_to_headbutt")


func _on_running_state_processing(_delta: float) -> void:
	velocity.x = direction * RUN_VELOCITY
	animated_sprite.play("walk")
	if not is_on_floor():
		$StateChart.send_event("running_to_in_the_air")


func _on_idle_state_processing(_delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, RUN_VELOCITY)
	animated_sprite.play("idle")


func _on_kick_state_entered() -> void:
	$StateChart.send_event("kick_to_cannot_kick")


func _on_kick_state_processing(delta: float) -> void:
	animated_sprite.play("kick")


func _on_jump_state_entered() -> void:
	velocity.y = JUMP_VELOCITY
	did_jump.emit(JUMP_VELOCITY)
	$StateChart.send_event("jump_to_in_the_air")
	$StateChart.send_event("cannot_headbutt_to_can_headbutt")


func _on_in_the_air_state_physics_processing(delta: float) -> void:
	if is_on_floor():
		$StateChart.send_event("in_the_air_to_running")
		$StateChart.send_event("can_headbutt_to_cannot_headbutt")
	else:
		animated_sprite.play("jump")
		velocity.y += gravity * delta


func _on_face_right_state_entered() -> void:
	animated_sprite.flip_h = false
	$KickZone/KickCollider.transform.origin.x = kickzone_x
	$DribbleMarker.transform.origin.x = dribble_marker_x
	direction_faced = 1.0
	dribble_marker_position.emit($DribbleMarker.global_position)


func _on_face_left_state_entered() -> void:
	animated_sprite.flip_h = true
	$KickZone/KickCollider.transform.origin.x = -kickzone_x
	$DribbleMarker.transform.origin.x = -dribble_marker_x
	direction_faced = -1.0
	dribble_marker_position.emit($DribbleMarker.global_position)


func _on_headbutt_state_entered() -> void:
	velocity_x.emit(self.velocity.x)
	did_headbutt.emit()
	$StateChart.send_event("headbutt_to_cannot_headbutt")


func _on_dribble_state_physics_processing(delta: float) -> void:
	velocity_x.emit(self.velocity.x)


func _on_dribble_state_entered() -> void:
	dribble_marker_position.emit($DribbleMarker.global_position)
