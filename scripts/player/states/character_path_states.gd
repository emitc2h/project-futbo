class_name CharacterPathStates
extends Node

@export_group("Dependencies")
@export var character: CharacterBase
@export var sc: StateChart

@export_group("Parameters")
@export var stay_on_path_force: float = 50.0

## States Enum
enum State {ON_X_AXIS = 0, ON_PATH = 1}
var state: State = State.ON_X_AXIS

## State transition constants
const TRANS_TO_ON_X_AXIS: String = "Path: to on x-axis"
const TRANS_TO_ON_PATH: String = "Path: to on path"

## callables
var move_callable: Callable = Callable(self, "_velocity_on_x_axis")
var in_the_air_callable: Callable = Callable(self, "_velocity_on_x_axis")

## internal variable
var _path: CharacterPath = null


# on x-axis state
#----------------------------------------
func _on_on_xaxis_state_entered() -> void:
	state = State.ON_X_AXIS
	
	move_callable = Callable(self, "_velocity_on_x_axis")
	in_the_air_callable = Callable(self, "_velocity_on_x_axis")


# on path state
#----------------------------------------
func _on_on_path_state_entered() -> void:
	state = State.ON_PATH
	
	move_callable = Callable(self, "_velocity_on_path")
	in_the_air_callable = Callable(self, "_float_on_path")


#=======================================================
# UTILITY FUNCTIONS
#=======================================================
func _velocity_on_x_axis(input_magnitude: float) -> void:
	character.velocity.x = input_magnitude


func _velocity_on_path(input_magnitude: float) -> void:
	var offset: float = _path.curve.get_closest_offset(character.position)
	var closest_point: Vector3 = _path.curve.get_closest_point(character.position)
	var curve_transform: Transform3D = _path.curve.sample_baked_with_rotation(offset)
	var direction: Vector3 = curve_transform.basis.z
	
	character.rotation.y = Vector3(-1,0,0).signed_angle_to(direction, Vector3(0,1,0))
	
	if direction:
		var stay_on_path_correction: Vector3 = (closest_point - character.position)
		character.velocity.x = -input_magnitude * direction.x + stay_on_path_force * stay_on_path_correction.x
		character.velocity.z = -input_magnitude * direction.z + stay_on_path_force * stay_on_path_correction.z


func _float_on_path() -> void:
	var offset: float = _path.curve.get_closest_offset(character.position)
	var curve_transform: Transform3D = _path.curve.sample_baked_with_rotation(offset)
	var direction: Vector3 = curve_transform.basis.z
	
	character.rotation.y = Vector3(-1,0,0).signed_angle_to(direction, Vector3(0,1,0))
	
	var velocity_along_path_vec := Vector3(character.velocity.x, 0.0, character.velocity.z)
	var velocity_sign: float = sign(direction.dot(velocity_along_path_vec))
	
	var velocity_along_path: float = velocity_along_path_vec.length()
	
	if direction:
		character.velocity.x = velocity_sign * velocity_along_path * direction.x
		character.velocity.z = velocity_sign * velocity_along_path * direction.z
