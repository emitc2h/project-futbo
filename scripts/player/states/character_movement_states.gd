class_name CharacterMovementStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

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

# in the air state
#----------------------------------------
func _on_in_the_air_state_entered() -> void:
	state = State.IN_THE_AIR


func _on_in_the_air_state_physics_processing(delta: float) -> void:
	## Apply gravity
	character.velocity.y += gravity * delta
	character.velocity.x = fall_velocity_x
	
	if character.is_on_floor():
		sc.send_event(TRANS_TO_GROUNDED)

# grounded state
#----------------------------------------
func _on_grounded_state_entered() -> void:
	state = State.GROUNDED


func _on_grounded_state_physics_processing(_delta: float) -> void:
	if not character.is_on_floor():
		sc.send_event(TRANS_TO_IN_THE_AIR)
