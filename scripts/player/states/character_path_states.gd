class_name CharacterPathStates
extends CharacterStatesAbstractBase

@export_group("Parameters")
@export var stay_on_path_force: float = 50.0

## States Enum
enum State {ON_X_AXIS = 0, ON_PATH = 1}
var state: State = State.ON_X_AXIS

## State transition constants
const TRANS_TO_ON_X_AXIS: String = "Path: to on x-axis"
const TRANS_TO_ON_PATH: String = "Path: to on path"

## Settable Parameters
var path: CharacterPath = null
var cart: Node3D

## Internal variables
var path_previous_rotation: Quaternion
var path_current_rotation: Quaternion

## Signals
signal path_state_changed(move_callable: Callable)


# on x-axis state
#----------------------------------------
func _on_on_xaxis_state_entered() -> void:
	state = State.ON_X_AXIS
	character.direction_states.reset_left_right_axis()
	path_state_changed.emit(Callable(self, "_velocity_on_x_axis"))


# on path state
#----------------------------------------
func _on_on_path_state_entered() -> void:
	state = State.ON_PATH
	path_state_changed.emit(Callable(self, "_velocity_on_path"))


#=======================================================
# CALLABLES
#=======================================================
func _velocity_on_x_axis(input_magnitude: float) -> void:
	character.velocity.x = input_magnitude


func _velocity_on_path(input_magnitude: float) -> void:
	var player_pos: Vector3 = character.global_position - path.global_position
		
	var offset: float = path.curve.get_closest_offset(player_pos)
	var closest_point: Vector3 = path.curve.get_closest_point(player_pos)
	var curve_transform: Transform3D = path.curve.sample_baked_with_rotation(offset)
	var direction: Vector3 = curve_transform.basis.z
	
	var rotation_y: float = Vector3(-1,0,0).signed_angle_to(direction, Vector3(0,1,0))
	character.direction_states.define_left_right_axis(rotation_y)
	
	if direction:
		var stay_on_path_correction: Vector3 = (closest_point - player_pos)
		character.velocity.x = -input_magnitude * direction.x + stay_on_path_force * stay_on_path_correction.x
		character.velocity.z = -input_magnitude * direction.z + stay_on_path_force * stay_on_path_correction.z
