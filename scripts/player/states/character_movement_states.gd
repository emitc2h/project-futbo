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


# in the air state
#----------------------------------------
func _on_in_the_air_state_entered() -> void:
	state = State.IN_THE_AIR


# grounded state
#----------------------------------------

func _on_grounded_state_entered() -> void:
	state = State.GROUNDED
