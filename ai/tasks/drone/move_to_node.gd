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
	var position_delta: float = agent.get_mode_position().x - node.global_position.x
	var near: float = abs(position_delta) < distance_when_to_stop
	
	if near:
		arrived = true
	
	if arrived:
		agent.stop_moving(delta)
		if abs(agent.left_right_axis) < 0.01:
			return SUCCESS
		else:
			return RUNNING
	else:
		# Player is to the right of the drone and the drone faces the wrong way
		if position_delta < 0.0 and agent.direction == Enums.Direction.LEFT:
			agent.face_right()
			
		# Player is to the left of the drone
		if position_delta > 0.0 and agent.direction == Enums.Direction.RIGHT:
			agent.face_left()
		
		# Only move once the drone is done facing a different direction
		# This creates a more relaxed patrol loop
		if not agent.in_turn_state:
			agent.move_toward_x_pos(node.global_position.x, delta)
		return RUNNING
