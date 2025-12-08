@tool
class_name IsInPhysicsStateCondition
extends BTCondition

var drone: Drone

@export var expected_state: DronePhysicsModeStates.State

func _generate_name() -> String:
	return "Physics state expected to be " + DronePhysicsModeStates.State.keys()[expected_state]


func _setup() -> void:
	drone = agent as Drone


func _tick(_delta: float) -> Status:
	if drone.physics_mode_states.state == expected_state:
		return SUCCESS
	return FAILURE
