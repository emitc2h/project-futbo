@tool
class_name SetPhysicsAction
extends BTAction

const CHAR: String = "char"
const RIGID: String = "rigid"
const RAGDOLL: String = "ragdoll"
const DEAD: String = "dead"

@export_enum(CHAR, RIGID, RAGDOLL, DEAD) var phys_type: String

var drone: Drone

func _generate_name() -> String:
	return "Set physics to " + phys_type


func _setup() -> void:
	drone = agent as Drone


func _tick(delta: float) -> Status:
	match(phys_type):
		CHAR:
			drone.become_char()
		RIGID:
			drone.become_rigid()
		RAGDOLL:
			drone.become_ragdoll()
		DEAD:
			pass
	return SUCCESS
