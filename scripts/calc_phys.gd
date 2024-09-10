extends Node

func distance_x_positions(positionA: Vector2, positionB: Vector2) -> float:
	return abs(positionB.x - positionA.x)


func distance_x_nodes(nodeA: Node2D, nodeB: Node2D) -> float:
	return distance_x_positions(nodeA.global_position, nodeB.global_position)


func distance_x_node_position(nodeA: Node2D, positionB: Vector2) -> float:
	return distance_x_positions(nodeA.global_position, positionB)


# From nodeA to nodeB
func direction_x_positions(positionA: Vector2, positionB: Vector2) -> float:
	return sign(positionB.x - positionA.x)
	
