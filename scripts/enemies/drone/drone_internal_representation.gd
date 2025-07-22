class_name DroneInternalRepresentation
extends Node

@export_group("Dependency Injection")
@export var drone: Drone

## This class serves as the Drone's understanding of the world based on its monitoring
## Monitoring State Machines should push updates to this class, and Actions that need
## to rely on the world context should only read information about the world from here

## Information about the world
class WorldRepresentation:
	var patrol_marker_1_pos_x: float = 0.0
	var patrol_marker_2_pos_x: float = 0.0
	var patrol_center_pos_x: float = 0.0
	
	func initialize() -> void:
		patrol_center_pos_x = (patrol_marker_1_pos_x + patrol_marker_2_pos_x) / 2.0

## Information about the player
class PlayerRepresentation:
	var last_known_player_pos_x: float = 0.0
	
	func initialize() -> void:
		pass

## Information about the control node
class ControlNodeRepresentation:
	var last_known_control_node_pos_x: float = 0.0
	
	func initialize() -> void:
		pass

## The state
var worldRepresentation: WorldRepresentation = WorldRepresentation.new()
var playerRepresentation: PlayerRepresentation = PlayerRepresentation.new()
var controlNodeRepresentation: ControlNodeRepresentation = ControlNodeRepresentation.new()

func initialize() -> void:
	worldRepresentation.initialize()
	playerRepresentation.initialize()
	controlNodeRepresentation.initialize()
