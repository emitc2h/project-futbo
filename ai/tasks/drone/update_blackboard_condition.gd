class_name DroneUpdateBlackboardCondition
extends BTCondition

var drone: Drone

@export var player_repr_global_position: StringName = &"internal_player_repr_global_position"
@export var player_repr_velocity: StringName = &"internal_player_repr_velocity"
@export var player_repr_is_dribbling: StringName = &"internal_player_repr_is_dribbling"
@export var player_repr_is_dead: StringName = &"internal_player_repr_is_dead"
@export var player_repr_shield_charges: StringName = &"internal_player_repr_shield_charges"
@export var player_repr_is_long_kicking: StringName = &"internal_player_repr_is_long_kicking"
@export var drone_sees_player: StringName = &"internal_drone_sees_player"

@export var control_node_repr_global_position: StringName = &"internal_control_node_repr_global_position"
@export var control_node_repr_velocity: StringName = &"internal_control_node_repr_velocity"
@export var control_node_repr_power_on: StringName = &"internal_control_node_repr_power_on"
@export var control_node_repr_charges: StringName = &"internal_control_node_repr_charges"
@export var control_node_repr_shield_expanded: StringName = &"internal_control_node_repr_shield_expanded"
@export var drone_sees_control_node: StringName = &"internal_drone_sees_control_node"


func _setup() -> void:
	drone = agent as Drone


func _enter() -> void:
	blackboard.set_var(player_repr_global_position, drone.repr.playerRepresentation.global_position)
	blackboard.set_var(player_repr_velocity, drone.repr.playerRepresentation.velocity)
	blackboard.set_var(player_repr_is_dribbling, drone.repr.playerRepresentation.is_dribbling)
	blackboard.set_var(player_repr_is_dead, drone.repr.playerRepresentation.is_dead)
	blackboard.set_var(player_repr_shield_charges, drone.repr.playerRepresentation.personal_shield_charges)
	blackboard.set_var(player_repr_is_long_kicking, drone.repr.playerRepresentation.is_long_kicking)
	blackboard.set_var(drone_sees_player, drone.repr.drone_sees_player)
	
	blackboard.set_var(control_node_repr_global_position, drone.repr.controlNodeRepresentation.global_position)
	blackboard.set_var(control_node_repr_velocity, drone.repr.controlNodeRepresentation.velocity)
	blackboard.set_var(control_node_repr_power_on, drone.repr.controlNodeRepresentation.power_on)
	blackboard.set_var(control_node_repr_charges, drone.repr.controlNodeRepresentation.charges)
	blackboard.set_var(control_node_repr_shield_expanded, drone.repr.controlNodeRepresentation.shield_expanded)
	blackboard.set_var(drone_sees_control_node, drone.repr.drone_sees_control_node)


func _tick(_delta: float) -> Status:
	return SUCCESS
