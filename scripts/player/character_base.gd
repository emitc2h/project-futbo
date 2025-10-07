class_name CharacterBase
extends CharacterBody3D

## asset
@export_group("Character Asset")
@export var asset: CharacterAssetBase

## state machines
@export_group("State Machines")
@export var direction_states: CharacterDirectionFacedStates

@export var movement_states: CharacterMovementStates
@export var grounded_states: CharacterGroundedStates
@export var in_the_air_states: CharacterInTheAirStates
@export var path_states: CharacterPathStates

@export var damage_states: CharacterDamageStates

## Internal references
@onready var sc: StateChart = $State


func _ready() -> void:
	path_states.path_state_changed.connect(_on_path_state_changed)


func idle() -> void:
	grounded_states.left_right_axis = 0.0
	asset.speed = 0.0
	if direction_states.mode == direction_states.Mode.FACING and\
	   grounded_states.state == grounded_states.State.MOVING:
		sc.send_event(grounded_states.TRANS_TO_IDLE)


func move(left_right_axis: float) -> void:
	grounded_states.left_right_axis = left_right_axis
	asset.speed = left_right_axis
	if grounded_states.state == grounded_states.State.IDLE:
		sc.send_event(grounded_states.TRANS_TO_MOVING)


#################################
## Signal handling             ##
#################################
func _on_path_state_changed(move_callable: Callable, in_the_air_callable: Callable) -> void:
	grounded_states.move_callable = move_callable
	grounded_states.in_the_air_callable = in_the_air_callable
