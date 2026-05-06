class_name ScoutOrbitingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var look_at_target: Marker3D

## States Enum
enum State {TARGETING = 0, LOOPING = 1}
var state: State = State.TARGETING

## State transition constants
const TRANS_TO_TARGETING: String = "Orbiting: to targeting"
const TRANS_TO_LOOPING: String = "Orbiting: to looping"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")

## Internal parameters
var _exhaust_intensity: float = 0.0
var is_orbit_motion_clockwise: bool = true
var _orbit_size: float = 3.0


# targeting state
#----------------------------------------
func _on_targeting_state_entered() -> void:
	state = State.TARGETING
	scout.targeting_states.lock_target()
	scout.quick_open()
	is_orbit_motion_clockwise = randi_range(0, 1)


func _on_targeting_state_physics_processing(delta: float) -> void:
	## turn off engine
	_exhaust_intensity = lerp(_exhaust_intensity, 0.0, scout.lerp_factor * delta)
	scout.asset.set_exhaust_intensity(_exhaust_intensity)
	
	## Update the look_at_target with the actual target
	look_at_target.global_position = look_at_target.global_position.lerp(scout.targeting_states.target.global_position, scout.lerp_factor * delta)
	
	## Make the drone face the target
	char_node.look_at(look_at_target.global_position)
	
	## Start with the perpendicular motion component
	var final_velocity: Vector3 = (2 * int(is_orbit_motion_clockwise) - 1) * char_node.transform.basis.x * scout.targeting_speed
	
	## Add the axial motion component
	var distance_to_target: float = char_node.global_position.distance_to(scout.targeting_states.target.global_position)
	final_velocity += char_node.transform.basis.z * (_orbit_size - distance_to_target)
	
	char_node.velocity = char_node.velocity.lerp(final_velocity, scout.lerp_factor * delta)


# looping state
#----------------------------------------
func _on_looping_state_entered() -> void:
	state = State.LOOPING
