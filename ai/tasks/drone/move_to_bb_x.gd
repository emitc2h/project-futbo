@tool
extends MoveTo

@export var destination_x: BBFloat


func _get_destination_name() -> String:
	return "x = " + str(destination_x)


func _get_destination_x() -> float:
	return destination_x.get_value(scene_root, blackboard)
