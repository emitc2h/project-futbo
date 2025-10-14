class_name PlayerKnockedStates
extends Node

## External references (player)
@export var player_basic_movement: PlayerBasicMovement
@export var sc: StateChart
var player: Player

## States Enum
enum State {KNOCKED = 0, RECOVERING = 1, DOWN = 2}
var state: State

const TRANS_KNOCKED_TO_RECOVERING: String = "Knocked: knocked to recovering"
const TRANS_KNOCKED_TO_OUT: String = "Knocked: knocked to out"

const TRANS_OUT_TO_RECOVERING: String = "Knocked: out to recovering"

## Internal variables
var object_velocity: Vector3
var object_position: Vector3

var knocked_anim_state: String
var recovery_anim_state: String

var initial_knockback_velocity_x: float
var current_knockback_velocity_x: float = 0.0


func _ready() -> void:
	player = player_basic_movement.player
	Signals.player_knocked.connect(_on_player_knocked)
	player.asset.anim_state_finished.connect(_on_anim_state_finished)


#=======================================================
# STATES
#=======================================================

# knocked state
#----------------------------------------
func _on_player_knocked(obj_velocity: Vector3, obj_position: Vector3) -> void:
	## Cache object data
	object_velocity = obj_velocity
	object_position = obj_position
	initial_knockback_velocity_x = object_velocity.x


func _on_knocked_state_entered() -> void:
	state = State.KNOCKED
	
	var player_position: Vector3 = player.global_position
	var player_direction_faced: Enums.Direction = player_basic_movement.direction_faced
	
	var delta_y: float = object_position.y - player_position.y
	
	## go straight to recovering state if the player is on the ground, otherwise pass by the out state
	if player.is_on_floor():
		player.asset.auto_recover = true
	else:
		player.asset.auto_recover = false
	
	## Player faces right, object is to the right
	if (object_position.x > player_position.x) and player_direction_faced == Enums.Direction.RIGHT:
		if delta_y > 1.0:
			player.asset.to_knocked_head_front()
			knocked_anim_state = "knocked head front"
		else:
			player.asset.to_knocked_middle_front()
			knocked_anim_state = "knocked middle front"
		recovery_anim_state = "get up back"
	
	## Player faces right, object is to the left
	if (object_position.x < player_position.x) and player_direction_faced == Enums.Direction.RIGHT:
		if delta_y > 1.0:
			player.asset.to_knocked_head_back()
			knocked_anim_state = "knocked head back"
		else:
			player.asset.to_knocked_middle_back()
			knocked_anim_state = "knocked middle back"
		recovery_anim_state = "get up front"

	## Player faces left, object is to the left
	if (object_position.x < player_position.x) and player_direction_faced == Enums.Direction.LEFT:
		if delta_y > 1.0:
			player.asset.to_knocked_head_front()
			knocked_anim_state = "knocked head front"
		else:
			player.asset.to_knocked_middle_front()
			knocked_anim_state = "knocked middle front"
		recovery_anim_state = "get up back"
	
	## Player faces left, object is to the right
	if (object_position.x > player_position.x) and player_direction_faced == Enums.Direction.LEFT:
		if delta_y > 1.0:
			player.asset.to_knocked_head_back()
			knocked_anim_state = "knocked head back"
		else:
			player.asset.to_knocked_middle_back()
			knocked_anim_state = "knocked middle back"
		recovery_anim_state = "get up front"
	
	current_knockback_velocity_x = initial_knockback_velocity_x


func _on_knocked_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		player_basic_movement.move_process(delta)
		player.asset.auto_recover = true
	else:
		player_basic_movement.fall_process(delta)
	player.velocity.x += current_knockback_velocity_x
	current_knockback_velocity_x = lerp(current_knockback_velocity_x, 0.0, 5.0*delta)
	player.move_and_slide()


# out state
#----------------------------------------
func _on_out_state_physics_processing(delta: float) -> void:
	if player.is_on_floor():
		sc.send_event(TRANS_OUT_TO_RECOVERING)
		player.asset.to_recover_from_knocked(recovery_anim_state)
	else:
		player_basic_movement.fall_process(delta)


# recovering state
#----------------------------------------
func _on_recovering_state_entered() -> void:
	state = State.RECOVERING


# down state
#----------------------------------------
func _on_down_state_entered() -> void:
	state = State.DOWN


func _on_anim_state_finished(anim_name: String) -> void:
	## At the end of the knocked animation
	if anim_name == knocked_anim_state:
		if player.asset.auto_recover and player.is_on_floor():
			sc.send_event(TRANS_KNOCKED_TO_RECOVERING)
		elif (not player.asset.auto_recover) and player.is_on_floor():
			player.asset.to_recover_from_knocked(recovery_anim_state)
			sc.send_event(TRANS_KNOCKED_TO_RECOVERING)
		elif (not player.asset.auto_recover) and (not player.is_on_floor()):
			sc.send_event(TRANS_KNOCKED_TO_OUT)
	
	if anim_name == recovery_anim_state:
		sc.send_event("knocked to idle")
