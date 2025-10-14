class_name CharacterDribbleStates
extends CharacterStatesAbstractBase

## States Enum
enum State {NO_BALL = 0, INTENDS_TO_DRIBBLE = 1, CAN_DRIBBLE = 2, DRIBBLING = 3}
var state: State = State.NO_BALL

@export_group("Mechanism Nodes")
@export var dribble_pickup_zone: Area3D
@export var dribble_marker: Marker3D
@export var dribble_raycast: RayCast3D
@export_subgroup("Dribble RayCast parameters")
@export var dribble_raycast_max_length: float = 0.9


# Dynamic properties
var ball: Ball

## State transition constants
const TRANS_TO_NO_BALL: String = "Dribble: to no ball"
const TRANS_TO_INTENDS_TO_DRIBBLE: String = "Dribble: to intends to dribble"
const TRANS_TO_CAN_DRIBBLE: String = "Dribble: to can dribble"
const TRANS_TO_DRIBBLING: String = "Dribble: to dribbling"

## Internal variables
var init_raycast_target_position: Vector3


func _ready() -> void:
	init_raycast_target_position = dribble_raycast.target_position


# no ball state
#----------------------------------------
func _on_no_ball_state_entered() -> void:
	state = State.NO_BALL
	ball = null


# intends to dribble state
#----------------------------------------
func _on_intends_to_dribble_state_entered() -> void:
	state = State.INTENDS_TO_DRIBBLE


# can dribble state
#----------------------------------------
func _on_can_dribble_state_entered() -> void:
	state = State.CAN_DRIBBLE


func _on_can_dribble_state_physics_processing(_delta: float) -> void:
	
	var overlapping_bodies: Array[Node3D] = dribble_pickup_zone.get_overlapping_bodies()
	
	if overlapping_bodies.is_empty():
		sc.send_event(TRANS_TO_NO_BALL)
	else:
		for body in overlapping_bodies:
			if body.is_in_group("BallGroup"):
				ball = body.get_parent()
				sc.send_event(TRANS_TO_DRIBBLING)


# dribbling state
#----------------------------------------
func _on_dribbling_state_entered() -> void:
	state = State.DRIBBLING
	
	## make the ball identify the player dribbling
	ball.own(character.get_instance_id())
	
	## If the ball accepts ownership, start dribbling
	if character.get_instance_id() == ball.dribbler_id:
		ball.start_dribbling()
		## Ensure the ball can be kicked when it's being dribbled
		character.kick_states.ball = ball
		sc.send_event(character.kick_states.TRANS_TO_CAN_KICK)
	else:
		sc.send_event(TRANS_TO_CAN_DRIBBLE)


func _on_dribbling_state_physics_processing(_delta: float) -> void:
	## Track the ball with the raycast
	dribble_raycast.target_position = (dribble_raycast.transform.inverse() * character.transform.inverse() * ball.get_transform_without_rotation()).origin
	#dribble_raycast.force_update_transform()
	dribble_raycast.force_raycast_update()
	
	if (not dribble_raycast.is_colliding()) or (dribble_raycast.target_position.length() > dribble_raycast_max_length):
		sc.send_event(TRANS_TO_CAN_DRIBBLE)
	
	## Ensures the ball is attracted to the dribble marker
	if character.get_instance_id() == ball.dribbler_id:
		Signals.active_dribble_marker_position_updated.emit(dribble_marker.global_position)
		Signals.player_velocity_updated.emit(character.velocity)
	else:
		sc.send_event(TRANS_TO_CAN_DRIBBLE)


func _on_dribbling_state_exited() -> void:
	## Reset dribble cast target
	dribble_raycast.target_position = init_raycast_target_position
	
	# if this character is the dribbler, end dribbling and ownership
	if character.get_instance_id() == ball.dribbler_id:
		ball.end_dribbling()
		ball.disown(character.get_instance_id())


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_dribble_pickup_zone_body_entered(body: Node3D) -> void:
	## When the ball's rigid node is taken away from collision layer 3 while in the pickup zone,
	## it triggers a body_exited signal. When the char node is put into collision layer 3, it
	## triggers a body_entered signal. 
	if body.is_in_group("BallGroup"):
		var this_ball: Ball = body.get_parent()
		if state == State.INTENDS_TO_DRIBBLE:
			ball = this_ball
			sc.send_event(TRANS_TO_DRIBBLING)
		elif state == State.NO_BALL:
			ball = this_ball
			sc.send_event(TRANS_TO_CAN_DRIBBLE)


func _on_dribble_pickup_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("BallGroup"):
		if state == State.CAN_DRIBBLE:
			sc.send_event(TRANS_TO_NO_BALL)


#=======================================================
# CONTROLS
#=======================================================
func dribble() -> void:
	if ball:
		sc.send_event(TRANS_TO_DRIBBLING)


func engage_dribble_intent() -> void:
	sc.send_event(TRANS_TO_INTENDS_TO_DRIBBLE)


func disengage_dribble_intent() -> void:
	sc.send_event(TRANS_TO_CAN_DRIBBLE)


func ball_jump(velocity_y: float) -> void:
	if ball and character.get_instance_id() == ball.dribbler_id:
		ball.physics_states.char_node.velocity.y += velocity_y
