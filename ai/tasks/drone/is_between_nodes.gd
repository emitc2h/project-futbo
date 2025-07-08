@tool
extends BTCondition

@export var node1: BBNode
@export var node2: BBNode
@export var tolerance: float

var drone: Drone

func _setup() -> void:
	drone = agent as Drone


func _generate_name() -> String:
	return "Is between " + str(node1) + " and " + str(node2)

func _tick(delta: float) -> Status:
	var x1: float = node1.get_value(scene_root, blackboard).global_position.x
	var x2: float = node2.get_value(scene_root, blackboard).global_position.x
	var x: float = drone.char_node.global_position.x
	var distance_to_node1: float = abs(x - x1)
	var distance_to_node2: float = abs(x - x2)
	var distance_between_nodes: float = abs(x1 - x2)
	
	if (distance_to_node1 + distance_to_node2) - distance_between_nodes < tolerance:
		return SUCCESS
	return FAILURE
