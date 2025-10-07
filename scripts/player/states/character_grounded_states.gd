class_name CharacterGroundedStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

@export_group("Linked State Machines")
@export var direction_states: CharacterDirectionFacedStates

## Parameters
@export_group("Movement")
@export var jump_velocity: float = 3.8

## States Enum
enum State {IDLE = 0, MOVING= 1, MOVING_BUFFER = 2, JUMP = 3}
var state: State = State.IDLE

## State transition constants
const TRANS_TO_IDLE: String = "Grounded: to idle"
const TRANS_TO_MOVING: String = "Grounded: to moving"
const TRANS_TO_JUMP: String = "Grounded: to jump"

## Settable Parameters
var left_right_axis: float = 0.0
var move_callable: Callable
var in_the_air_callable: Callable


# idle state
#----------------------------------------
func _on_idle_state_entered() -> void:
	state = State.IDLE
	character.asset.idle()


func _on_idle_state_physics_processing(_delta: float) -> void:
	## Make sure to neutralize movement, but still look for collisions
	move_callable.call(0.0)
	
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
	move_callable.call(direction_states.direction_sign(left_right_axis) * character.asset.root_motion_position.x/delta)
	
	direction_states.turn_based_on_axis(left_right_axis)
	
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()


# jump state
#----------------------------------------
func _on_jump_state_entered() -> void:
	state = State.JUMP
	
	character.velocity.y = jump_velocity
	character.movement_states.fall_velocity_x = character.velocity.x
	
	## Call move_and_slide
	character.move_and_slide()
	
	character.asset.jump()
	
	sc.send_event(character.movement_states.TRANS_TO_IN_THE_AIR)
