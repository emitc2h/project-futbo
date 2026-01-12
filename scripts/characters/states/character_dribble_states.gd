class_name CharacterDribbleStates
extends CharacterStatesAbstractBase

## States Enum
enum State {NOT_DRIBBLING = 0, DRIBBLING = 1}
var state: State = State.NOT_DRIBBLING

@export_group("Mechanism Nodes")
@export var dribble_pickup_zone: Area3D
@export var dribble_marker: Marker3D
@export var dribble_raycast: RayCast3D
@export_subgroup("Dribble RayCast parameters")
@export var dribble_raycast_max_length: float = 0.9

# Dynamic properties
var ball: Ball

## State transition constants
const TRANS_TO_DRIBBLING: String = "Dribble: to dribbling"
const TRANS_TO_NOT_DRIBBLING: String = "Dribble: to not dribbling"

## Internal variables
var init_raycast_target_position: Vector3
var _dribble_button_pressed: bool = false
var _ball_is_in_pickup_zone: bool = false

var character_is_kicking: bool = false


func _ready() -> void:
	init_raycast_target_position = dribble_raycast.target_position
	Signals.control_node_requests_destination.connect(_on_control_node_requests_destination)


# not dribbling state
#----------------------------------------
func _on_not_dribbling_state_entered() -> void:
	state = State.NOT_DRIBBLING
	ball = null


func _on_not_dribbling_state_physics_processing(_delta: float) -> void:
	if not _dribble_button_pressed:
		return
	
	if character_is_kicking:
		return
	
	## Continuous pickup zone monitoring
	var retrieved_ball: Ball = retrieve_ball_in_pickup_zone()
	if retrieved_ball:
		ball = retrieved_ball
		_ball_is_in_pickup_zone = true
	else:
		_ball_is_in_pickup_zone = false
	
	if not _ball_is_in_pickup_zone:
		return
		
	## If you've made it this far, all the conditions are met to start dribbling
	sc.send_event(TRANS_TO_DRIBBLING)


# dribbling state
#----------------------------------------
func _on_dribbling_state_entered() -> void:
	state = State.DRIBBLING
	if character.is_player:
		Signals.dribbling_entered.emit()
		Representations.player_representation.is_dribbling = true
	
	## make the ball identify the player dribbling
	ball.own(character.get_instance_id())
	
	## If the ball accepts ownership, start dribbling
	if character.get_instance_id() == ball.dribbler_id:
		ball.start_dribbling()
		## Ensure the ball can be kicked when it's being dribbled
		character.kick_states.ball = ball
		sc.send_event(character.kick_states.TRANS_TO_CAN_KICK)
	else:
		sc.send_event(TRANS_TO_NOT_DRIBBLING)


func _on_dribbling_state_physics_processing(_delta: float) -> void:
	if character_is_kicking or (not _dribble_button_pressed):
		sc.send_event(TRANS_TO_NOT_DRIBBLING)
		return
	
	## Track the ball with the raycast
	dribble_raycast.target_position = (dribble_raycast.transform.inverse() * character.transform.inverse() * ball.get_transform_without_rotation()).origin
	dribble_raycast.force_raycast_update()
	
	## If the dribble cast isn't finding the ball, exit DRIBBLING
	if (not dribble_raycast.is_colliding()):
		sc.send_event(TRANS_TO_NOT_DRIBBLING)
		return
	
	## If the raycast is too long while the ball being outside of the pickup zone, exit DRIBBLING
	if (dribble_raycast.target_position.length() > dribble_raycast_max_length) and not (retrieve_ball_in_pickup_zone()):
		sc.send_event(TRANS_TO_NOT_DRIBBLING)
		return
	
	## Ensures the ball is attracted to the dribble marker
	if ball and character.get_instance_id() == ball.dribbler_id:
		## Make sure the destination of the control node is on the xy-plane
		var marker_pos: Vector3 = Vector3(dribble_marker.global_position.x, dribble_marker.global_position.y, 0.0)
		Signals.active_dribble_marker_position_updated.emit(marker_pos)
		Signals.player_velocity_updated.emit(character.velocity)
	else:
		sc.send_event(TRANS_TO_NOT_DRIBBLING)
		return


func _on_dribbling_state_exited() -> void:
	if character.is_player:
		Signals.dribbling_exited.emit()
		Representations.player_representation.is_dribbling = false
	
	## Reset dribble cast target
	dribble_raycast.target_position = init_raycast_target_position
	
	# if this character is the dribbler, end dribbling and ownership
	if ball and character.get_instance_id() == ball.dribbler_id:
		ball.end_dribbling()
		ball.disown(character.get_instance_id())


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_control_node_requests_destination() -> void:
	## Make sure the destination of the control node is on the xy-plane
	var destination: Vector3 = Vector3(dribble_marker.global_position.x, dribble_marker.global_position.y, 0.0)
	Signals.player_update_destination.emit(destination)


func _on_dribble_pickup_zone_body_exited(body: Node3D) -> void:
	## The character is done kicking when the ball exits the pickup zone.
	## If the ball gets confined within the pickup zone while kicking this may cause
	## problems.
	if body.is_in_group("BallGroup"):
		character_is_kicking = false

#=======================================================
# CONTROLS
#=======================================================
func dribble() -> void:
	if ball and not character_is_kicking:
		sc.send_event(TRANS_TO_DRIBBLING)


func engage_dribble_intent() -> void:
	_dribble_button_pressed = true


func disengage_dribble_intent() -> void:
	_dribble_button_pressed = false


func ball_jump(velocity_y: float) -> void:
	if ball and character.get_instance_id() == ball.dribbler_id:
		ball.physics_states.char_node.velocity.y += velocity_y


#=======================================================
# UTILS
#=======================================================
func retrieve_ball_in_pickup_zone() -> Ball:
	for body in dribble_pickup_zone.get_overlapping_bodies():
		if body.is_in_group("BallGroup"):
			return body.get_parent() as Ball
	return null
