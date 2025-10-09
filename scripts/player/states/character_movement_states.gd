class_name CharacterMovementStates
extends CharacterStatesAbstractBase

@export_group("Linked State Machines")
@export var in_the_air_states: CharacterInTheAirStates

@export_group("Movement Parameters")
@export var coyote_time: float = 0.04

## States Enum
enum State {IN_THE_AIR = 0, GROUNDED = 1}
var state: State = State.IN_THE_AIR

## State transition constants
const TRANS_TO_IN_THE_AIR: String = "Movement: to in the air"
const TRANS_TO_GROUNDED: String = "Movement: to grounded"

# Static/Internal properties
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

## Internal variables
var fall_velocity_x: float = 0.0
var coyote_timer: float = 0.0

## Settable Parameters
var move_callable: Callable
var rotation_callable: Callable

# in the air state
#----------------------------------------
func _on_in_the_air_state_entered() -> void:
	state = State.IN_THE_AIR


func _on_in_the_air_state_physics_processing(delta: float) -> void:
	## Apply gravity
	character.velocity.y += gravity * delta
	move_callable.call(fall_velocity_x)
	rotation_callable.call()
	
	if character.is_on_floor():
		sc.send_event(TRANS_TO_GROUNDED)

# grounded state
#----------------------------------------
func _on_grounded_state_entered() -> void:
	state = State.GROUNDED
	in_the_air_states.set_initial_state(in_the_air_states.State.FALLING)
	coyote_timer = 0.0


func _on_grounded_state_physics_processing(delta: float) -> void:
	if not character.is_on_floor():
		coyote_timer += delta
	else:
		coyote_timer = 0.0
	
	if coyote_timer > coyote_time:
		sc.send_event(TRANS_TO_IN_THE_AIR)
