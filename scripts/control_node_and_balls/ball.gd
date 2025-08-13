class_name Ball
extends Node3D

# Internal references
@onready var sc: StateChart = $State

## state machines
@export_group("State Machines")
@export var physics_states: BallPhysicsStates
@export var control_states: BallControlStates

var dribbler_id: int:
	get:
		return control_states.dribbler_id
	set(value):
		control_states.dribbler_id = value

var is_owned: bool:
	get:
		return control_states.is_owned
	set(value):
		control_states.is_owned = value

signal kicked

#=======================================================
# CONTROL FUNCTIONS
#=======================================================
func impulse(force_vector: Vector3) -> void:
	end_dribbling()
	physics_states.rigid_node.set_impulse(force_vector)
	kicked.emit()


func kick(force_vector: Vector3) -> void:
	self.impulse(force_vector)


func long_kick(force_vector: Vector3) -> void:
	self.impulse(force_vector)


func own(player_id: int) -> void:
	if not control_states.is_owned:
		control_states.dribbler_id = player_id
		control_states.is_owned = true


func disown(player_id: int) -> void:
	if control_states.dribbler_id == player_id:
		control_states.dribbler_id = 0
		control_states.is_owned = false


func start_dribbling() -> void:
	sc.send_event(control_states.TRANS_FREE_TO_DRIBBLED)


func end_dribbling() -> void:
	sc.send_event(control_states.TRANS_TO_FREE)


func get_ball_position() -> Vector3:
	if physics_states.state == physics_states.State.RIGID:
		return physics_states.rigid_node.global_position
	else:
		return physics_states.char_node.global_position


func get_ball_velocity() -> Vector3:
	if physics_states.state == physics_states.State.RIGID:
		return physics_states.rigid_node.linear_velocity
	else:
		return physics_states.char_node.velocity
