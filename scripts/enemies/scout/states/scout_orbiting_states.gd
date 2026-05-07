class_name ScoutOrbitingStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout
@export var sc: StateChart
@export var look_at_target: Marker3D
@export var repulsor_field: ScoutRepulsorField

@onready var num_scout_collision_decay_timer: Timer = $NumScoutCollisionDecayTimer

@export_group("Parameters")
@export_subgroup("Orbit trajectory")
@export var orbit_speed_factor_min: float = 0.6
@export var orbit_speed_factor_max: float = 1.0
@export var orbit_radius_min: float = 1.4
@export var orbit_radius_max: float = 3.6
@export var orbit_angle_min_rad: float = 0.1
@export var orbit_angle_max_rad: float = 0.4

@export_subgroup("Looping triggers")
## Maximum number of collisions with other scouts allowed before engaging in looping.
@export var max_num_scout_collisions: int = 30
## How many collisions to subtract from the total per second. Prevents rare collisions from triggering looping.
@export var num_scout_collision_decay_rate: float = 1.0
## How far down can the scout look down before triggering looping. Meant to prevent gimbal lock.
@export var max_look_down_angle_degrees: float = 68.0
## How far away from the player should the scout be to trigger looping. Meant to prevent orbit decay.
@export var max_orbit_distances: float = 2.4
@export_subgroup("Looping trajectory")
@export var looping_vertical_min: float = 3.0
@export var looping_vertical_max: float = 7.5
@export var looping_horizontal_min: float = 5.0
@export var looping_horizontal_max: float = 10.0


## States Enum
enum State {TARGETING = 0, LOOPING = 1}
var state: State = State.TARGETING

## State transition constants
const TRANS_TO_LOOPING: String = "Orbiting: to looping"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = scout.get_node("CharNode")

## Internal parameters
var _exhaust_intensity: float = 0.0
var _is_orbit_motion_clockwise: bool = true
var _orbit_size: float = 2.0
var _orbit_angle: float = 0.0
var _speed_modifier: float = 1.0

var _tw_look_at_target_pos_y: Tween
var _tw_look_at_target_pos_x: Tween
var _tw_look_at_target_pos_z: Tween
var _num_scout_collsions: int = 0
var _looping_distance: float = 0.0
var _start_looping_pos: Vector3 = Vector3.ZERO


func _ready() -> void:
	## Initialize the scout collision detection to enable transition to looping
	_num_scout_collsions = 0
	repulsor_field.colliding_with_other_scout.connect(_on_colliding_with_other_scout)
	num_scout_collision_decay_timer.timeout.connect(_on_num_scout_collision_decay_timer_timeout)
	num_scout_collision_decay_timer.wait_time = 1.0/num_scout_collision_decay_rate
	num_scout_collision_decay_timer.start()


# targeting state
#----------------------------------------
func _on_targeting_state_entered() -> void:
	state = State.TARGETING
	scout.targeting_states.lock_target()
	scout.quick_open()
	_is_orbit_motion_clockwise = randi_range(0, 1)
	_speed_modifier = randf_range(orbit_speed_factor_min, orbit_speed_factor_max)
	_orbit_size = randf_range(orbit_radius_min, orbit_radius_max)
	_orbit_angle = randf_range(orbit_angle_min_rad, orbit_angle_max_rad)


func _on_targeting_state_physics_processing(delta: float) -> void:
	## turn off engine
	_exhaust_intensity = lerp(_exhaust_intensity, 0.0, scout.lerp_factor * delta)
	scout.asset.set_exhaust_intensity(_exhaust_intensity)
	
	## Update the look_at_target with the actual target
	look_at_target.global_position = look_at_target.global_position.lerp(scout.targeting_states.target.global_position, scout.lerp_factor * delta)
	
	## First, make the char node look directly at the target to set the velocities
	char_node.look_at(scout.targeting_states.target.global_position)
	
	## Start with the perpendicular motion component
	var final_velocity: Vector3 = (2 * int(_is_orbit_motion_clockwise) - 1) * char_node.transform.basis.x * scout.targeting_speed * _speed_modifier
	
	## Add vertical motion component
	final_velocity += char_node.transform.basis.y * sin(char_node.rotation.y) * _orbit_angle * scout.targeting_speed * _speed_modifier
	
	## Add the axial motion component
	var distance_to_target: float = char_node.global_position.distance_to(scout.targeting_states.target.global_position)
	var orbit_correction_factor: float = (_orbit_size - distance_to_target)
	final_velocity += char_node.transform.basis.z * orbit_correction_factor * scout.targeting_speed
	
	## Normalize back velocity
	final_velocity = final_velocity.normalized() * scout.targeting_speed * _speed_modifier
	
	## Go to looping if the orbit gets out of control
	if abs(char_node.rotation_degrees.x) > max_look_down_angle_degrees:
		sc.send_event(TRANS_TO_LOOPING)
		return
	
	if distance_to_target > (max_orbit_distances * _orbit_size):
		sc.send_event(TRANS_TO_LOOPING)
		return
	
	## Finally set the lerped look_at for smoothing the orientation of the scout
	char_node.look_at(look_at_target.global_position)
	
	char_node.velocity = char_node.velocity.lerp(final_velocity, scout.lerp_factor * delta)


# looping state
#----------------------------------------
func _on_looping_state_entered() -> void:
	state = State.LOOPING
	
	## Pick a new look_at target
	## First, determine how high to go
	var loop_endpoint_pos: Vector3 = Vector3.UP * randf_range(looping_vertical_min, looping_vertical_max)
	
	## Second, how far to go horizontally
	loop_endpoint_pos += Vector3.FORWARD * randf_range(looping_horizontal_min, looping_horizontal_min)
	
	## Third, pick which orientation to go to
	loop_endpoint_pos = loop_endpoint_pos.rotated(Vector3.UP, randf_range(0.0, 2 * PI))
	
	## Put the loop_endpoint_pos in global space
	loop_endpoint_pos += scout.targeting_states.target.global_position
	
	## Record the looping distance to establish a criteria for when the scout heads back
	## Reduce the looping distance a bit to make sure the scout never actually reaches it
	_start_looping_pos = char_node.global_position
	_looping_distance = 0.9 * (loop_endpoint_pos - _start_looping_pos).length()
	var curve_duration: float = _looping_distance / scout.speed
	
	## Tween the look_at_target to this new position
	_tw_look_at_target_pos_y = create_tween()
	_tw_look_at_target_pos_y.tween_property(look_at_target, "global_position:y", loop_endpoint_pos.y, curve_duration)\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CIRC)
	
	_tw_look_at_target_pos_x = create_tween()
	_tw_look_at_target_pos_x.tween_property(look_at_target, "global_position:x", loop_endpoint_pos.x, curve_duration)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_CIRC)
	
	_tw_look_at_target_pos_z = create_tween()
	_tw_look_at_target_pos_z.tween_property(look_at_target, "global_position:z", loop_endpoint_pos.z, curve_duration)\
	.set_ease(Tween.EASE_IN)\
	.set_trans(Tween.TRANS_CIRC)

	## Transition to looping behavior
	scout.targeting_states.release_target()
	scout.quick_close()


func _on_looping_state_physics_processing(delta: float) -> void:
	## Look at the marker
	char_node.look_at(look_at_target.global_position)
	
	## Compute direction vector
	var look_at_direction_vector: Vector3 = (look_at_target.global_position - char_node.global_position).normalized()
	
	## Move the scout along that direction
	char_node.velocity = char_node.velocity.lerp(look_at_direction_vector * scout.speed, scout.lerp_factor * delta)
	
	## Exhaust matches velocity
	_exhaust_intensity = lerp(_exhaust_intensity, 1.0, scout.lerp_factor * delta)
	scout.asset.set_exhaust_intensity(_exhaust_intensity)
	
	var distance_to_player: float = (char_node.global_position - Representations.player_target_marker.global_position).length()
	var distance_traveled: float = (char_node.global_position - _start_looping_pos).length()
	if distance_to_player >= _looping_distance or distance_traveled > _looping_distance:
		sc.send_event(scout.behavior_states.TRANS_TO_GO_TO_PLAYER)


func _on_looping_state_exited() -> void:
	if _tw_look_at_target_pos_y.is_running() or _tw_look_at_target_pos_x.is_running() or _tw_look_at_target_pos_z.is_running():
		_tw_look_at_target_pos_y.kill()
		_tw_look_at_target_pos_x.kill()
		_tw_look_at_target_pos_z.kill()


# signal handling
#========================================
func _on_colliding_with_other_scout() -> void:
	_num_scout_collsions += 1
	if _num_scout_collsions > max_num_scout_collisions:
		sc.send_event(TRANS_TO_LOOPING)
		_num_scout_collsions = 0


func _on_num_scout_collision_decay_timer_timeout() -> void:
	if _num_scout_collsions > 0:
		_num_scout_collsions -= 1
	num_scout_collision_decay_timer.start()
