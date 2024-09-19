extends Node

# Reference to the player
var player: Player

# Some common utility functions
func distance_to_target(target_position: Vector3) -> float:
	return CalcPhys.distance_x_node_position(player, target_position)
