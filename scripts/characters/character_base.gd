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
@export var kick_states: CharacterKickStates
@export var dribble_states: CharacterDribbleStates
@export var targeting_states: CharacterTargetingStates
@export var shield: CharacterShield

## Settable Parameters
var is_player: bool = false

## Internal references
@onready var sc: StateChart = $State
@onready var target_marker: Marker3D = $TargetMarker


func _ready() -> void:
	if is_player:
		Representations.player_target_marker = target_marker


## Update the player representation
func _physics_process(_delta: float) -> void:
	if is_player:
		Representations.player_representation.global_position = self.global_position
		Representations.player_representation.velocity = self.velocity
	

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
	direction_states.lock_direction_faced()


func unlock_direction_faced(left_right_axis: float) -> void:
	direction_states.unlock_direction_faced(left_right_axis)


func face_left() -> void:
	direction_states.face_left()


func face_right() -> void:
	direction_states.face_right()


func kick() -> void:
	kick_states.kick()


func dribble() -> void:
	dribble_states.dribble()


func is_dribbling() -> bool:
	return dribble_states.state == dribble_states.State.DRIBBLING
