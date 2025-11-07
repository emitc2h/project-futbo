class_name DronePhysicsModeStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var engines_states: DroneEnginesStates

## Parameters
@export_group("Movement")
@export var axis_lerp_strength: float = 4.0

@export_group("Floating")
@export var float_cast_length: float = 2.2
@export var float_strength: float = 4.0
@export var float_dampening: float = 4.0
@export var oscillation_amplitude: float = 0.015
@export var oscillation_frequency: float = 3.0

## States Enum
enum State {CHAR = 0, RIGID = 1, RAGDOLL = 2, DEAD = 3}
var state: State = State.CHAR

## State transition constants
const TRANS_TO_RIGID: String = "Physics Mode: to rigid"
const TRANS_TO_CHAR: String = "Physics Mode: to char"
const TRANS_TO_RAGDOLL: String = "Physics Mode: to ragdoll"
const TRANS_TO_DEAD: String = "Physics Mode: to dead"

## Drone nodes controlled by this state
@onready var char_node: CharacterBody3D = drone.get_node("CharNode")
@onready var rigid_node: InertNode = drone.get_node("RigidNode")

@onready var track_transform_container: Node3D = drone.get_node("TrackTransformContainer")
@onready var track_position_container: Node3D = drone.get_node("TrackPositionContainer")

@onready var collision_shape_char: CollisionShape3D = drone.get_node("CharNode/CollisionShape3D")
@onready var collision_shape_rigid: CollisionShape3D = drone.get_node("RigidNode/CollisionShape3D")

@onready var float_cast: RayCast3D = drone.get_node("TrackPositionContainer/FloatCast")
@onready var float_distortion_animation: DroneFloatDistortionAnimation = drone.get_node("FloatDistortionAnimation")

@onready var model_anim_tree: AnimationTree = track_transform_container.get_node("DroneModel/AnimationTree")
@onready var bone_simulation: PhysicalBoneSimulator3D = track_transform_container.get_node("DroneModel/Armature/Skeleton3D/PhysicalBoneSimulator3D")

## Timers
@onready var dead_timer: Timer = $DeadTimer

## Internal variables
var time_floating: float = 0.0
var gravity: float = -ProjectSettings.get_setting("physics/3d/default_gravity")

## Settable Parameters
var speed: float = 3.0
var left_right_axis: float = 0.0

## Signals
signal char_entered
signal rigid_entered


func _ready() -> void:
	collision_shape_rigid.disabled = true
	collision_shape_char.disabled = false
	set_ragdoll_collisions(false)


# char state
#----------------------------------------
func _on_char_state_entered() -> void:
	state = State.CHAR
	
	## reset time floating
	time_floating = 0.0
	
	## char node takes ownership of transform
	char_node.transform = rigid_node.transform

	## Stop all motion leftover from previous states
	left_right_axis = 0.0
	
	## Reset speed
	speed = engines_states.off_speed

	## Turn on float distortion
	float_distortion_animation.turn_on()
	
	## Turn on collision shape
	collision_shape_char.disabled = false
	
	char_entered.emit()


func _on_char_state_physics_processing(delta: float) -> void:
	## increment time floating
	time_floating += delta
	
	## Gravity is always on in char mode
	if not char_node.is_on_floor():
		char_node.velocity.y += gravity * delta
	
	
	if float_cast.is_colliding():
		## Detect the ground and push against the ground
		var lift_factor: float = 1.0 - (abs(float_cast.get_collision_point().y - float_cast.global_position.y) / float_cast_length)**2
		char_node.velocity.y += -gravity * float_strength * lift_factor * delta
		
		## dampen the oscillation
		char_node.velocity.y -= float_dampening * char_node.velocity.y * delta
		
		## little bit of a floating animation
		char_node.velocity.y -= oscillation_amplitude * sin( oscillation_frequency * time_floating )
	
	## Apply horizontal speed
	char_node.velocity.x = lerp(char_node.velocity.x, left_right_axis * speed, axis_lerp_strength * delta)
	
	char_node.move_and_slide()
	
	## nodes tha must follow the char node
	track_transform_container.transform = char_node.transform
	track_position_container.position = char_node.position
	
	## rigid node follows char node
	rigid_node.transform = char_node.transform


func _on_char_state_exited() -> void:	
	## turn off the float distortion
	float_distortion_animation.turn_off()
	
	## Turn off collision shape
	collision_shape_char.disabled = true


# rigid state
#----------------------------------------
func _on_rigid_state_entered() -> void:
	state = State.RIGID
	
	## wake up the rigid node
	rigid_node.wake_up()
	
	## rigid node takes ownership of transform
	rigid_node.set_transform_and_velocity(char_node.global_transform, char_node.velocity)
	char_node.velocity = Vector3.ZERO
	
	## Enable rigid node colliions
	collision_shape_rigid.disabled = false
	
	rigid_entered.emit()


func _on_rigid_state_physics_processing(_delta: float) -> void:
	## nodes tha must follow the rigid node
	track_transform_container.transform = rigid_node.transform
	track_position_container.position = rigid_node.position
	
	## char node follows rigid node
	char_node.transform = rigid_node.transform


func _on_rigid_state_exited() -> void:
	## Disable rigid node colliions
	collision_shape_rigid.disabled = true
	
	## Put the rigid node to sleep
	rigid_node.sleep()


# ragdoll state
#----------------------------------------
func _on_ragdoll_state_entered() -> void:
	state = State.RAGDOLL
	
	## Transformation to ragdoll state is meant to be irreversible
	## disable all other collision shapes
	collision_shape_rigid.queue_free()
	collision_shape_char.queue_free()
	set_ragdoll_collisions(true)
	
	## Disable animations
	model_anim_tree.active = false
	
	## Disable and queue_free everything else
	sc.send_event(drone.targeting_states.TRANS_TO_DISABLED)
	sc.send_event(drone.proximity_states.TRANS_TO_DISABLED)
	track_position_container.queue_free()
	track_transform_container.get_node("FieldOfView").queue_free()
	track_transform_container.get_node("ProximityDetector").queue_free()
	
	## Start the ragdoll simulation
	bone_simulation.physical_bones_start_simulation()
	
	dead_timer.start()
	
	## End the encounter, reset the zoom
	Signals.update_zoom.emit(Enums.Zoom.DEFAULT)


func _on_dead_timer_timeout() -> void:
	dead_timer.stop()
	sc.send_event(TRANS_TO_DEAD)


func _on_ragdoll_state_exited() -> void:
	bone_simulation.physical_bones_stop_simulation()


# dead state
#----------------------------------------
func _on_dead_state_entered() -> void:
	state = State.DEAD
	drone.queue_free()
	Signals.drone_died.emit()


#=======================================================
# CONTROLS
#=======================================================
func set_ragdoll_collisions(enabled: bool) -> void:
	for bone in bone_simulation.get_children():
		var col_shape: CollisionShape3D = bone.get_node("CollisionShape3D")
		col_shape.disabled = !enabled
