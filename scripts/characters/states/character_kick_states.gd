class_name CharacterKickStates
extends CharacterStatesAbstractBase

## States Enum
enum State {NO_BALL = 0, CAN_KICK = 1, KICK = 2, INTENDS_TO_LONG_KICK = 3, WINDING_UP_LONG_KICK = 4, LONG_KICK = 5}
var state: State = State.NO_BALL

@export_group("Mechanism Nodes")
@export var kick_zone: Area3D
@export var long_kick_zone: Area3D
@export var long_kick_raycast: RayCast3D

@export_group("Properties")
@export var kick_force: float = 7.0
@export var long_kick_force: float = 14.0
@export var long_kick_trigger_distance: float = 0.4

## State transition constants
const TRANS_TO_NO_BALL: String = "Kick: to no ball"
const TRANS_TO_CAN_KICK: String = "Kick: to can kick"
const TRANS_KICK_TO_CAN_KICK: String = "Kick: kick to can kick"
const TRANS_TO_KICK: String = "Kick: to kick"

const TRANS_TO_INTENDS_TO_LONG_KICK: String = "Kick: to intends to long kick"
const TRANS_TO_WINDING_UP_LONG_KICK: String = "Kick: to winding up long kick"
const TRANS_LONG_KICK_TO_CAN_KICK: String = "Kick: long kick to can kick"
const TRANS_TO_LONG_KICK: String = "Kick: to long kick"

## Dynamic properties
var ball: Ball

## Internal variables
var try_to_engage_long_kick_intent: bool = false


# no ball state
#----------------------------------------
func _on_no_ball_state_entered() -> void:
	state = State.NO_BALL
	ball = null


func _on_no_ball_state_physics_processing(_delta: float) -> void:
	if try_to_engage_long_kick_intent and not long_kick_raycast.is_colliding():
		sc.send_event(TRANS_TO_INTENDS_TO_LONG_KICK)


# can kick state
#----------------------------------------
func _on_can_kick_state_entered() -> void:
	state = State.CAN_KICK


func _on_can_kick_state_physics_processing(_delta: float) -> void:
	## If the ball leaves the kick zone while not being dribbled, got to no ball state
	if not retrieve_ball_in_kick_zone():
		sc.send_event(TRANS_TO_NO_BALL)


# kick state
#----------------------------------------
func _on_kick_state_entered() -> void:
	state = State.KICK
	ball.kick(Aim.vector * kick_force)
	
	## Prevent changes in direction while kicking
	character.direction_states.lock_direction_faced()
	character.dribble_states.character_is_kicking = true
	
	## End the kick state when the animation is finished to make sure it ends at some point
	await character.asset.kick()
	sc.send_event(TRANS_KICK_TO_CAN_KICK)


func _on_kick_state_physics_processing(_delta: float) -> void:
	## Wait till the ball has left the zones to end the kick state
	if (not retrieve_ball_in_kick_zone()) and (not character.dribble_states.retrieve_ball_in_pickup_zone()):
		sc.send_event(TRANS_TO_NO_BALL)


func _on_kick_state_exited() -> void:
	character.direction_states.unlock_direction_faced(character.grounded_states.left_right_axis)


# intends to long kick state
#----------------------------------------
func _on_intends_to_long_kick_state_entered() -> void:
	state = State.INTENDS_TO_LONG_KICK


func _on_intends_to_long_kick_state_physics_processing(_delta: float) -> void:
	if long_kick_raycast.is_colliding():
		sc.send_event(TRANS_TO_WINDING_UP_LONG_KICK)


# winding up to long kick state
#----------------------------------------
func _on_winding_up_long_kick_state_entered() -> void:
	state = State.WINDING_UP_LONG_KICK
	if long_kick_raycast.is_colliding():
		var collider: Node3D = long_kick_raycast.get_collider() as Node3D
		if collider.get_parent() is Ball:
			ball = collider.get_parent()
	character.asset.long_kick()


func _on_winding_up_long_kick_state_physics_processing(_delta: float) -> void:
	if not long_kick_raycast.is_colliding():
		sc.send_event(TRANS_LONG_KICK_TO_CAN_KICK)
	else:
		long_kick_raycast.force_raycast_update()
		var distance_to_ball: float = abs(long_kick_raycast.get_collision_point().x - character.global_position.x)
		if distance_to_ball < long_kick_trigger_distance:
			sc.send_event(TRANS_TO_LONG_KICK)


# long kick state
#----------------------------------------
func _on_long_kick_state_entered() -> void:
	state = State.LONG_KICK
	ball.long_kick(Aim.vector * long_kick_force)
	
	## Prevent changes in direction while kicking
	character.direction_states.lock_direction_faced()
	
	character.dribble_states.character_is_kicking = true
	
	## End the kick state when the animation is finished to make sure it ends at some point
	await character.asset.long_kick_finished
	sc.send_event(TRANS_LONG_KICK_TO_CAN_KICK)


func _on_long_kick_state_physics_processing(_delta: float) -> void:
	## Wait till the ball has left the zones to end the long kick state
	if (not retrieve_ball_in_kick_zone()) and (not character.dribble_states.retrieve_ball_in_pickup_zone()):
		sc.send_event(TRANS_TO_NO_BALL)


func _on_long_kick_state_exited() -> void:
	character.direction_states.unlock_direction_faced(character.grounded_states.left_right_axis)

#=======================================================
# SIGNALS
#=======================================================
func _on_kick_zone_body_entered(body: Node3D) -> void:
	if body.is_in_group("BallGroup"):
		ball = body.get_parent() as Ball
		sc.send_event(TRANS_TO_CAN_KICK)


func _on_kick_zone_body_exited(body: Node3D) -> void:
	if body.is_in_group("BallGroup"):
		ball = body.get_parent() as Ball
		# prevents ball from being unkickable while dribbling, even if it falls out of the kick zone
		if (not ball) or (ball.dribbler_id != character.get_instance_id()):
			sc.send_event(TRANS_TO_NO_BALL)


#=======================================================
# CONTROLS
#=======================================================
func kick() -> void:
	## Disallow kicking while running backward
	if not character.direction_states.running_backward(character.grounded_states.left_right_axis):
		sc.send_event(TRANS_TO_KICK)


func engage_long_kick_intent() -> void:
	try_to_engage_long_kick_intent = true


func disengage_long_kick_intent() -> void:
	try_to_engage_long_kick_intent = false
	sc.send_event(TRANS_LONG_KICK_TO_CAN_KICK)


#=======================================================
# UTILS
#=======================================================
func retrieve_ball_in_kick_zone() -> Ball:
	for body in kick_zone.get_overlapping_bodies():
		if body.is_in_group("BallGroup"):
			return body.get_parent() as Ball
	return null
