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
	if movement_states.state == movement_states.State.GROUNDED and \
	grounded_states.state == grounded_states.State.MOVING:
		sc.send_event(grounded_states.TRANS_TO_IDLE)
		grounded_states.left_right_axis = 0.0
		asset.speed = 0.0


func move(left_right_axis: float) -> void:
	grounded_states.left_right_axis = left_right_axis
	if movement_states.state == movement_states.State.GROUNDED:
		if direction_states.locked:
			asset.speed = direction_states.face_sign() * left_right_axis
		else:
			asset.speed = abs(left_right_axis)
		if grounded_states.state == grounded_states.State.IDLE:
			sc.send_event(grounded_states.TRANS_TO_MOVING)
	
	## If the character is in the air, decide what state they should land on
	if movement_states.state == movement_states.State.IN_THE_AIR:
		if left_right_axis == 0.0:
			grounded_states.set_initial_state(grounded_states.State.IDLE)
		elif not direction_states.faced_direction_is_consistent_with_axis(left_right_axis):
			grounded_states.set_initial_state(grounded_states.State.TURN)
		else:
			grounded_states.set_initial_state(grounded_states.State.MOVING)

func jump() -> void:
	sc.send_event(grounded_states.TRANS_TO_JUMP)


func get_on_path(path: CharacterPath) -> void:
	path_states.path = path
	sc.send_event(path_states.TRANS_TO_ON_PATH)


func get_off_path() -> void:
	path_states.path = null
	sc.send_event(path_states.TRANS_TO_ON_X_AXIS)


func lock_direction_faced() -> void:
	direction_states.locked = true


func unlock_direction_faced() -> void:
	direction_states.locked = false


func face_left() -> void:
	direction_states.face_left()


func face_right() -> void:
	direction_states.face_right()


#################################
## Signal handling             ##
#################################
func _on_path_state_changed(move_callable: Callable, rotation_callable: Callable) -> void:
	grounded_states.move_callable = move_callable
	grounded_states.rotation_callable = rotation_callable
	movement_states.move_callable = move_callable
	movement_states.rotation_callable = rotation_callable
