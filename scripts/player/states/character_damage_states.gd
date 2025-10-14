class_name CharacterDamageStates
extends CharacterStatesAbstractBase

@export_group("Knock Height")
## The height (and above) at which the animation blend is 100% head knock, 0% middle knock
@export var max_height_delta_y: float = 1.0
## The height (and below) at which the animation blend is 0% head knock, 100% middle knock
@export var min_height_delta_y: float = 0.0

## States Enum
enum State {ABLE = 0, KNOCKED = 1, OUT = 2, RECOVERING = 3, DOWN = 4}
var state: State = State.ABLE

## State transition constants
const TRANS_TO_ABLE: String = "Damage: to able"
const TRANS_TO_KNOCKED: String = "Damage: to knocked"
const TRANS_TO_OUT: String = "Damage: to out"
const TRANS_TO_RECOVERING: String = "Damage: to recovering"
const TRANS_TO_DOWN: String = "Damage: to down"

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

## Settable Parameters
var move_callable: Callable

## Internal variables
var _colliding_obj_velocity: Vector3
var _colliding_obj_position: Vector3

var _initial_knockback_velocity_x: float
var _current_knockback_velocity_x: float = 0.0


func _ready() -> void:
	character.asset.knocked_finished.connect(_on_knocked_finished)
	character.asset.recover_finished.connect(_on_recover_finished)


# able state
#----------------------------------------
func _on_able_state_entered() -> void:
	state = State.ABLE


# knocked state
#----------------------------------------
func _on_knocked_state_entered() -> void:
	state = State.KNOCKED
	
	## First compute the relative position of the colliding object and the player
	var char_pos: Vector3 = character.global_position
	var char_direction_faced: CharacterDirectionFacedStates.State = character.direction_states.state
	var delta_y: float = _colliding_obj_position.y - char_pos.y
	var norm_delta_y: float = clamp((delta_y - min_height_delta_y) / (max_height_delta_y - min_height_delta_y), 0.0, 1.0)
	
	## go straight to recovering state if the player is on the ground, otherwise pass by the out state
	if character.is_on_floor():
		character.asset.auto_recover_from_knocked = true
	else:
		character.asset.auto_recover_from_knocked = false
	
	## Decide on the blending 
	character.asset.vertical_knock_blend = 1.0

	## Player faces right, object is to the right - WORKS
	if (_colliding_obj_position.x > char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_RIGHT:
		character.asset.horizontal_knock_blend = 1.0
		character.asset.recover_blend = 1.0
	
	## Player faces right, object is to the left
	if (_colliding_obj_position.x < char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_RIGHT:
		print("## Player faces right, object is to the left")
		character.asset.horizontal_knock_blend = -1.0
		character.asset.recover_blend = -1.0

	## Player faces left, object is to the left
	if (_colliding_obj_position.x < char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_LEFT:
		print("## Player faces left, object is to the left")
		character.asset.horizontal_knock_blend = 1.0
		character.asset.recover_blend = 1.0
	
	## Player faces left, object is to the right - WORKS
	if (_colliding_obj_position.x > char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_LEFT:
		character.asset.horizontal_knock_blend = -1.0
		character.asset.recover_blend = -1.0

	character.asset.knock()
	
	_current_knockback_velocity_x = _initial_knockback_velocity_x


func _on_knocked_state_physics_processing(delta: float) -> void:
	if character.is_on_floor():
		## Picks up the move function from the path states and uses the root motion to compute the velocity
		move_callable.call(character.direction_states.face_sign() * character.asset.root_motion_position.x/delta)
		character.asset.auto_recover_from_knocked = true
	else:
		character.velocity.y += gravity * delta
		move_callable.call(_current_knockback_velocity_x)
		
	## When on a path, the rotation needs to be constantly applied but only when moving
	if character.path_states.state == character.path_states.State.ON_PATH:
		character.direction_states.apply_rotation()
	
	character.velocity.x += _current_knockback_velocity_x
	_current_knockback_velocity_x = lerp(_current_knockback_velocity_x, 0.0, 5.0*delta)
	
	character.move_and_slide()
		

# knocked state
#----------------------------------------
func _on_out_state_entered() -> void:
	state = State.OUT


# recovering state
#----------------------------------------
func _on_recovering_state_entered() -> void:
	state = State.RECOVERING
	character.asset.recover_from_knock()


func _on_recovering_state_physics_processing(delta: float) -> void:
	## Picks up the move function from the path states and uses the root motion to compute the velocity
	move_callable.call(character.direction_states.face_sign() * character.asset.root_motion_position.x/delta)
	character.move_and_slide()


func _on_recovering_state_exited() -> void:
	character.grounded_states.set_initial_state(character.grounded_states.State.IDLE)
	character.movement_states.set_initial_state(character.movement_states.State.GROUNDED)


# down state
#----------------------------------------
func _on_down_state_entered() -> void:
	state = State.DOWN


#=======================================================
# CONTROLS
#=======================================================
func knock(obj_velocity: Vector3, obj_position: Vector3) -> void:
	print("knock called")
	_colliding_obj_velocity = obj_velocity
	_colliding_obj_position = obj_position
	_initial_knockback_velocity_x = obj_velocity.x
	sc.send_event(TRANS_TO_KNOCKED)


#=======================================================
# SIGNALS
#=======================================================
func _on_knocked_finished() -> void:
	if character.asset.auto_recover_from_knocked and character.is_on_floor():
		sc.send_event(TRANS_TO_RECOVERING)
	elif (not character.asset.auto_recover_from_knocked) and character.is_on_floor():
		sc.send_event(TRANS_TO_RECOVERING)
	else:
		sc.send_event(TRANS_TO_OUT)


func _on_recover_finished() -> void:
	sc.send_event(TRANS_TO_ABLE)
