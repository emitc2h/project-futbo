@tool
extends BTAction

@export var destination_node: BBNode
@export var distance_when_to_stop: float

var arrived: bool = false

func _generate_name() -> String:
	return "Move to " + str(destination_node)

func _enter() -> void:
	arrived = false

func _tick(delta: float) -> Status:
	var node: Node3D = destination_node.get_value(scene_root, blackboard)
	#print("agent: ", agent.get_mode_position().x, ", target: ", node.global_position.x)
	var near: float = abs(agent.get_mode_position().x - node.global_position.x) < distance_when_to_stop
	
	if near:
		arrived = true
	
	if arrived:
		agent.stop_moving(delta)
		if abs(agent.left_right_axis) < 0.01:
			return SUCCESS
		else:
			return RUNNING
	else:
		agent.move_toward_x_pos(node.global_position.x, delta)
		return RUNNING
