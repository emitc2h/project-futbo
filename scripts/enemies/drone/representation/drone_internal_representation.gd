class_name DroneInternalRepresentation
extends Node

@export_group("Dependency Injection")
@export var drone: Drone

@export_group("Perception Parameters")
@export var visibility_range: float = 8.0

## This class serves as the Drone's understanding of the world based on its monitoring
## Monitoring State Machines should push updates to this class, and Actions that need
## to rely on the world context should only read information about the world from here

## The state
var worldRepresentation: DroneWorldRepresentation = DroneWorldRepresentation.new()
var playerRepresentation: PlayerRepresentation = PlayerRepresentation.new()
var controlNodeRepresentation: ControlNodeRepresentation = ControlNodeRepresentation.new()


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	var drone_pos: Vector3 = drone.char_node.global_position
	if drone_pos.distance_to(Representations.player_representation.global_position) < visibility_range:
		if drone.is_facing_toward(Representations.player_representation.global_position.x):
			update_player_repr_from_buffer()
	
	if drone_pos.distance_to(Representations.control_node_representation.global_position) < visibility_range:
		if drone.is_facing_toward(Representations.control_node_representation.global_position.x):
			update_control_node_repr_from_buffer()


## Signal handling
##=========================================
func update_player_repr_from_buffer() -> void:
	playerRepresentation = Representations.player_representation.duplicate()


func update_control_node_repr_from_buffer() -> void:
	controlNodeRepresentation = Representations.control_node_representation.duplicate()
