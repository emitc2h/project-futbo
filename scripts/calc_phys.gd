extends Node

func distance_x_positions(positionA: Vector3, positionB: Vector3) -> float:
	return abs(positionB.x - positionA.x)


func distance_x_nodes(nodeA: Node3D, nodeB: Node3D) -> float:
	return distance_x_positions(nodeA.global_position, nodeB.global_position)


func distance_x_node_position(nodeA: Node3D, positionB: Vector3) -> float:
	return distance_x_positions(nodeA.global_position, positionB)


# From nodeA to nodeB
func direction_x_positions(positionA: Vector3, positionB: Vector3) -> float:
	return sign(positionB.x - positionA.x)
	
