@tool
extends MoveTo

@export var destination_node: BBNode


func _get_destination_name() -> String:
	return str(destination_node)


func _get_destination_x() -> float:
	return destination_node.get_value(scene_root, blackboard).global_position.x
