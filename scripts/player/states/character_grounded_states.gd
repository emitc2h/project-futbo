class_name CharacterGroundedStates
extends CharacterStatesAbstractBase

@export_group("Linked State Machines")
@export var direction_states: CharacterDirectionFacedStates
@export var in_the_air_states: CharacterInTheAirStates

## Parameters
@export_group("Movement")
@export var jump_velocity: float = 3.8

## States Enum
enum State {IDLE = 0, MOVING = 1, JUMP = 2, TURN = 3}
var state: State = State.MOVING

@export_group("State Mapping")
@export var state_map: Dictionary[State, StateChartState]

## State transition constants
const TRANS_TO_IDLE: String = "Grounded: to idle"
const TRANS_TO_MOVING: String = "Grounded: to moving"
const TRANS_TO_JUMP: String = "Grounded: to jump"
const TRANS_TO_TURN: String = "Grounded: to turn"

## Settable Parameters
var left_right_axis: float = 0.0
var move_callable: Callable


func _ready() -> void:
	character.asset.turn_finished.connect(_on_turn_finished)


# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	state = State.IDLE
	character.asset.idle()


func _on_idle_state_physics_processing(_delta: float) -> void:
	## Make sure to neutralize movement, but still look for collisions
	move_callable.call(0.0)
	
	character.movement_states.fall_velocity_x = character.velocity.x
	
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()


func _on_idle_state_exited() -> void:
	direction_states.face_direction_based_on_axis(left_right_axis)


# moving state
#----------------------------------------
func _on_moving_state_entered() -> void:
	state = State.MOVING
	character.asset.move()


func _on_moving_state_physics_processing(delta: float) -> void:
	## Picks up the move function from the path states and uses the root motion to compute the velocity
	move_callable.call(direction_states.move_sign(left_right_axis) * character.asset.root_motion_position.x/delta)
	
	if not direction_states.faced_direction_is_consistent_with_axis(left_right_axis):
		sc.send_event(TRANS_TO_TURN)
		return
	
	character.movement_states.fall_velocity_x = character.velocity.x
	
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()
	
	## When on a path, the rotation needs to be constantly applied but only when moving
	if character.path_states.state == character.path_states.State.ON_PATH:
		character.direction_states.apply_rotation()


# jump state
#----------------------------------------
func _on_jump_state_entered() -> void:
	state = State.JUMP
	
	## Initiate jump
	character.velocity.y = jump_velocity
	character.movement_states.fall_velocity_x = character.velocity.x
	character.move_and_slide()
	
	## Animation
	character.asset.jump()
	
	## State change
	in_the_air_states.set_initial_state(in_the_air_states.State.JUMPING)
	sc.send_event(character.movement_states.TRANS_TO_IN_THE_AIR)


# turn state
#----------------------------------------
func _on_turn_state_entered() -> void:
	state = State.TURN
	direction_states.switch_direction()
	character.asset.turn()


func _on_turn_state_physics_processing(delta: float) -> void:
	## Picks up the move function from the path states and uses the root motion to compute the velocity
	move_callable.call(direction_states.turn_sign() * character.asset.root_motion_position.x/delta)
	
	character.movement_states.fall_velocity_x = character.velocity.x
	
	## Call move_and_slide
	character.move_and_slide()
	
	character.quaternion *= character.asset.root_motion_rotation


func _on_turn_finished() -> void:
	direction_states.cement_rotation()
	sc.send_event(TRANS_TO_MOVING)


#=======================================================
# CONTROLS
#=======================================================
func set_initial_state(new_initial_state: State) -> void:
	cs._initial_state = state_map[new_initial_state]
