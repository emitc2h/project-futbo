class_name Scout
extends Node3D

@onready var sc: StateChart = $State

## asset
@export_group("Assets")
@export var asset: ScoutAsset

## state machines
@export_group("State Machines")
@export_subgroup("Function State Machines")
@export var physics_states: ScoutPhysicsStates
@export var char_states: ScoutCharStates
@export var engagement_states: ScoutEngagementStates

@export_subgroup("Monitoring State Machines")
@export var targeting_states: ScoutTargetingStates

@onready var anim_state: AnimationNodeStateMachinePlayback = asset.anim_state


## Engagement Controls
## ---------------------------------------
signal open_finished(id: int)
func open(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["idle", "thrust idle", "open", "quick open"]:
		sc.send_event(engagement_states.TRANS_TO_OPEN)
		await engagement_states.open_finished
	open_finished.emit(id)


signal quick_open_finished(id: int)
func quick_open(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["idle", "thrust idle", "quick open"]:
		sc.send_event(engagement_states.TRANS_TO_QUICK_OPEN)
		await engagement_states.quick_open_finished
	quick_open_finished.emit(id)


signal close_finished(id: int)
func close(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["closed", "close", "quick close"]:
		sc.send_event(engagement_states.TRANS_TO_CLOSE)
		await engagement_states.close_finished
	close_finished.emit(id)


signal quick_close_finished(id: int)
func quick_close(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["closed", "quick close"]:
		sc.send_event(engagement_states.TRANS_TO_QUICK_CLOSE)
		await engagement_states.quick_close_finished
	quick_close_finished.emit(id)


## Targeting Controls
## ---------------------------------------
func lock_target() -> bool:
	var locked: bool = targeting_states.lock_target()
	if locked:
		sc.send_event(char_states.TRANS_TO_TARGET)
	return locked


func release_target() -> void:
	targeting_states.release_target()
	sc.send_event(char_states.TRANS_TO_MOVE)
