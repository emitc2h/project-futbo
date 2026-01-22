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

## internal variables
var player_repr_update_enabled: bool = true
var control_node_repr_update_enabled: bool = true

## meta variables
var drone_sees_player: bool = false
var drone_sees_control_node: bool = false


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	var drone_pos: Vector3 = drone.char_node.global_position
	drone_sees_player = false
	if drone_pos.distance_to(Representations.player_representation.global_position) < visibility_range:
		if drone.is_facing_toward(Representations.player_representation.global_position.x):
			drone_sees_player = true
			update_player_repr_from_buffer()
	
	drone_sees_control_node = false
	if drone_pos.distance_to(Representations.control_node_representation.global_position) < visibility_range:
		if drone.is_facing_toward(Representations.control_node_representation.global_position.x):
			drone_sees_control_node = true
			update_control_node_repr_from_buffer()


## Signal handling
##=========================================
func update_player_repr_from_buffer() -> void:
	if player_repr_update_enabled:
		playerRepresentation = Representations.player_representation.duplicate()


func update_control_node_repr_from_buffer() -> void:
	if control_node_repr_update_enabled:
		controlNodeRepresentation = Representations.control_node_representation.duplicate()


## Controls
##=========================================
func enable_player_updates() -> void:
	player_repr_update_enabled = true


func disable_player_updates() -> void:
	player_repr_update_enabled = false


func enable_control_node_updates() -> void:
	control_node_repr_update_enabled = true


func disable_control_node_updates() -> void:
	control_node_repr_update_enabled = false


func enable_updates() -> void:
	enable_player_updates()
	enable_control_node_updates()


func disable_updates() -> void:
	disable_player_updates()
	disable_control_node_updates()


func force_update() -> void:
	playerRepresentation = Representations.player_representation.duplicate()
	controlNodeRepresentation = Representations.control_node_representation.duplicate()
