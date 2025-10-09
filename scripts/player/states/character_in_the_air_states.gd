class_name CharacterInTheAirStates
extends CharacterStatesAbstractBase

## States Enum
enum State {JUMPING = 0, FALLING = 1}
var state: State = State.FALLING

@export_group("Mechanism Nodes")
@export var jump_raycast: RayCast3D
@export_subgroup("Jump Raycast Properties")
@export_range(0.0, 5.0, 0.05) var jump_raycast_length: float = 1.6

@export_group("State Mapping")
@export var state_map: Dictionary[State, StateChartState]

## State transition constants
const TRANS_TO_FALLING: String = "In the air: to falling"


func _ready() -> void:
	jump_raycast.target_position = Vector3.DOWN * jump_raycast_length
	character.asset.fall_started.connect(_on_fall_animation_started)


# jumping state
#----------------------------------------
func _on_jumping_state_entered() -> void:
	state = State.JUMPING
	character.asset.close_jump_to_fall_path()


func _on_jumping_state_physics_processing(_delta: float) -> void:
	
	if not jump_raycast.is_colliding():
		character.asset.open_jump_to_fall_path()
	else:
		character.asset.close_jump_to_fall_path()
	
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()


# falling state
#----------------------------------------
func _on_falling_state_entered() -> void:
	state = State.FALLING
	character.asset.fall()


func _on_falling_state_physics_processing(_delta: float) -> void:
	## Call move_and_slide in each leaf of the movement HSM
	character.move_and_slide()


#=======================================================
# SIGNALS
#=======================================================
func _on_fall_animation_started() -> void:
	sc.send_event(TRANS_TO_FALLING)


#=======================================================
# CONTROLS
#=======================================================
func set_initial_state(new_initial_state: State) -> void:
	cs._initial_state = state_map[new_initial_state]
