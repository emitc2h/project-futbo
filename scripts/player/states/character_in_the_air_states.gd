class_name CharacterInTheAirStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

## States Enum
enum State {IN_THE_AIR = 0, FALLING = 1}
var state: State = State.IN_THE_AIR

## State transition constants
const TRANS_TO_FALLING: String = "In the air: to falling"


# in the air state
#----------------------------------------
func _on_in_the_air_state_entered() -> void:
	state = State.IN_THE_AIR


# falling state
#----------------------------------------
func _on_falling_state_entered() -> void:
	state = State.FALLING
