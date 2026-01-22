class_name CharacterDamageStates
extends CharacterStatesAbstractBase

@export var min_hit_velocity: float = 3.0
@export var min_knock_velocity: float = 6.0
@export var min_death_velocity: float = 9.0

## States Enum
enum State {ABLE = 0, KNOCKED = 1, OUT = 2, RECOVERING = 3, DEAD = 4, HIT = 5}
var state: State = State.ABLE

## State transition constants
const TRANS_TO_ABLE: String = "Damage: to able"
const TRANS_TO_KNOCKED: String = "Damage: to knocked"
const TRANS_TO_OUT: String = "Damage: to out"
const TRANS_TO_RECOVERING: String = "Damage: to recovering"
const TRANS_TO_DEAD: String = "Damage: to dead"
const TRANS_TO_HIT: String = "Damage: to hit"

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
	character.asset.hit_finished.connect(_on_hit_finished)


# able state
#----------------------------------------
func _on_able_state_entered() -> void:
	state = State.ABLE


func _on_able_state_exited() -> void:
	## When able state is exited, the ball should be given a small impulse so it bounces away
	if character.dribble_states.state == character.dribble_states.State.DRIBBLING:
		character.dribble_states.ball.impulse(1.5 * Vector3(character.direction_states.face_sign(), 1.0, 0.0))


# knocked state
#----------------------------------------
func _on_knocked_state_entered() -> void:
	state = State.KNOCKED
	
	## Make sure the damage animation played is knock
	character.asset.open_knock_path()
	
	## go straight to recovering state if the player is on the ground, otherwise pass by the out state
	if character.is_on_floor():
		character.asset.auto_recover_from_knocked = true
	else:
		character.asset.auto_recover_from_knocked = false
	
	## Compute the animation blending 
	compute_blend(character.global_position, character.direction_states.state)

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


# dead state
#----------------------------------------
func _on_dead_state_entered() -> void:
	state = State.DEAD
	
	## Make sure the damage animation played is die
	character.asset.open_die_path()
	
	if character.is_on_floor():
		pass
	else:
		## Immediately transition to ragdoll
		pass
		
	## Compute the animation blending
	compute_blend(character.global_position, character.direction_states.state)

	character.asset.knock()
	
	_current_knockback_velocity_x = _initial_knockback_velocity_x
	
	become_untargetable(1.5)
	
	if character.is_player:
		Signals.player_dead.emit()
		Representations.player_representation.is_dead = true
	
		await get_tree().create_timer(1.0).timeout
		Signals.game_over.emit()


# hit state
#----------------------------------------
func _on_hit_state_entered() -> void:
	state = State.HIT

	## Make sure the damage animation played is die
	character.asset.open_hit_path()
	
	if character.is_on_floor():
		character.movement_states.set_initial_state(character.movement_states.State.GROUNDED)
	else:
		## Character is already disabled from moving in the air
		sc.send_event(TRANS_TO_ABLE)
		return
	
	## Compute the animation blending
	compute_blend(character.global_position, character.direction_states.state)
	
	character.asset.knock()
	
	_current_knockback_velocity_x = _initial_knockback_velocity_x


#=======================================================
# CONTROLS
#=======================================================
func take_damage(obj_velocity: Vector3, obj_position: Vector3, physical: bool) -> void:
	if physical:
		## Physical attacks are attacks made from colliding with another body
		## Only log those values from the initial hit
		if state == State.ABLE:
			_colliding_obj_velocity = obj_velocity
			_colliding_obj_position = obj_position
			_initial_knockback_velocity_x = obj_velocity.x
		
		## Body has enough velocity to kill the player
		if (obj_velocity.length() > min_death_velocity):
			if character.shield.take_single_hit():
				## If the shield is up, simply knock back the player
				sc.send_event(TRANS_TO_KNOCKED)
			else:
				## When the shield is down, the player dies
				sc.send_event(TRANS_TO_DEAD)
			return
		
		## Body has enough velocity to knock the player
		if (obj_velocity.length() > min_knock_velocity):
			## There's enough velocity to draw from the shield
			character.shield.take_single_hit()
			## Knock the player
			sc.send_event(TRANS_TO_KNOCKED)
			return
		
		## Body has enough velocity to stagger the player
		if (obj_velocity.length() > min_hit_velocity):
			sc.send_event(TRANS_TO_HIT)
			return
	
	if character.shield.take_single_hit():
		## If the shield is up, take a hit
		_initial_knockback_velocity_x = obj_velocity.x
		sc.send_event(TRANS_TO_HIT)
	else:
		## When the shield is down, the player dies
		_colliding_obj_velocity = obj_velocity
		_colliding_obj_position = obj_position
		_initial_knockback_velocity_x = obj_velocity.x
		sc.send_event(TRANS_TO_DEAD)


func become_untargetable(delay: float = 0.0) -> void:
	await get_tree().create_timer(delay).timeout
	## Take out player from collision layer so enemies won't detect it
	character.set_collision_layer_value(1, false)
	character.set_collision_mask_value(9, false)
	character.set_collision_mask_value(10, false)


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


func _on_hit_finished() -> void:
	sc.send_event(TRANS_TO_ABLE)


#=======================================================
# UTILS
#=======================================================
func compute_blend(char_pos: Vector3, char_direction_faced: CharacterDirectionFacedStates.State) -> void:
	## Decide on the blending 
	character.asset.vertical_knock_blend = 1.0

	## Player faces right, object is to the right
	if (_colliding_obj_position.x > char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_RIGHT:
		character.asset.horizontal_knock_blend = 1.0
		character.asset.recover_blend = 1.0
	
	## Player faces right, object is to the left
	if (_colliding_obj_position.x < char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_RIGHT:
		character.asset.horizontal_knock_blend = -1.0
		character.asset.recover_blend = -1.0

	## Player faces left, object is to the left
	if (_colliding_obj_position.x < char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_LEFT:
		character.asset.horizontal_knock_blend = 1.0
		character.asset.recover_blend = 1.0
	
	## Player faces left, object is to the right
	if (_colliding_obj_position.x > char_pos.x) and char_direction_faced == CharacterDirectionFacedStates.State.FACE_LEFT:
		character.asset.horizontal_knock_blend = -1.0
		character.asset.recover_blend = -1.0
