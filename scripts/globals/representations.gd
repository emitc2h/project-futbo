extends Node

## Player
@onready var player_representation: PlayerRepresentation = PlayerRepresentation.new()
var player_target_marker: Marker3D

## Control Node
@onready var control_node_representation: ControlNodeRepresentation = ControlNodeRepresentation.new()
var control_node_target_marker: Marker3D
