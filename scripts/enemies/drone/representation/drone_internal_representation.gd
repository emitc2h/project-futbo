class_name DroneInternalRepresentation
extends Node

@export_group("Dependency Injection")
@export var drone: Drone

## This class serves as the Drone's understanding of the world based on its monitoring
## Monitoring State Machines should push updates to this class, and Actions that need
## to rely on the world context should only read information about the world from here

## The state
var worldRepresentation: DroneWorldRepresentation = DroneWorldRepresentation.new()
var playerRepresentation: PlayerRepresentation = PlayerRepresentation.new()
var controlNodeRepresentation: ControlNodeRepresentation = ControlNodeRepresentation.new()


func _ready() -> void:
	pass


## Signal handling
##=========================================
func update_player_repr_from_buffer() -> void:
	playerRepresentation = Representations.player_representation.duplicate()


func update_control_node_repr_from_buffer() -> void:
	controlNodeRepresentation = Representations.control_node_representation.duplicate()
