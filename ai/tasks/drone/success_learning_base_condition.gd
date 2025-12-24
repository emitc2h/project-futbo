class_name DroneSuccessLearningBaseCondition
extends BTCondition

@export var record_name: String

const INTERNAL: String = "internal_"
const SUCCESS_BUFFER: String = "success_buffer_"

const player_repr_global_position: String = "player_repr_global_position"
const player_repr_velocity: String = "player_repr_velocity"
const player_repr_is_dribbling: String = "player_repr_is_dribbling"
const player_repr_is_dead: String = "player_repr_is_dead"
const player_repr_shield_charges: String = "player_repr_shield_charges"

const control_node_repr_global_position: String = "control_node_repr_global_position"
const control_node_repr_velocity: String = "control_node_repr_velocity"
const control_node_repr_power_on: String = "control_node_repr_power_on"
const control_node_repr_charges: String = "control_node_repr_charges"
const control_node_repr_shield_expanded: String = "control_node_repr_shield_expanded"

var drone: Drone

func _setup() -> void:
	drone = agent as Drone
