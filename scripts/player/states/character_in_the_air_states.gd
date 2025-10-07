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


func _on_in_the_air_state_physics_processing(_delta: float) -> void:
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()

# falling state
#----------------------------------------
func _on_falling_state_entered() -> void:
	state = State.FALLING


func _on_falling_state_physics_processing(_delta: float) -> void:
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()
