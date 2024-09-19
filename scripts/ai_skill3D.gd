extends Node

# Reference to the player
var player: Player3D

# Some common utility functions
func distance_to_target(target_position: Vector3) -> float:
	return CalcPhys3d.distance_x_node_position(player, target_position)
