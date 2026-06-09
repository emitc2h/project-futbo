class_name ScoutPhysicsStates
extends BallPhysicsStates

## Dependency Injection
@export_group("Dependencies")
@export var scout: Scout

## State transition constants
const TRANS_TO_RAGDOLL: String = "Physics: to ragdoll"


# ragdoll state
#----------------------------------------
func _on_ragdoll_state_entered() -> void:
	state = State.RAGDOLL
