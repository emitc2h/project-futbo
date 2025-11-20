class_name WaitFromControlNodeProximityExitedAction
extends BTAction

var drone: Drone
var done: bool


func _setup() -> void:
	drone = agent as Drone
	drone.proximity_states.control_node_proximity_exited.connect(_on_control_node_proximity_exited)


func _enter() -> void:
	done = false
	if drone.proximity_states.control_node_in_detector == false:
		done = true


func _tick(_delta: float) -> Status:
	if done:
		print("Done waiting for control node to exit the proximity zone")
		return SUCCESS
	return RUNNING


func _on_control_node_proximity_exited() -> void:
	done = true
