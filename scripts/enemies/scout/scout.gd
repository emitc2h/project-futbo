class_name Scout
extends Node3D

@onready var sc: StateChart = $State

## asset
@export_group("Assets")
@export var asset: ScoutAsset

## state machines
@export_group("State Machines")
@export_subgroup("Function State Machines")
@export var health_states: ScoutHealthStates
@export var movement_states: ScoutMovementStates
@export var orbiting_states: ScoutOrbitingStates
@export var in_plane_movement_states: ScoutInPlaneMovementStates
@export var engagement_states: ScoutEngagementStates
@export var spinner_states: ScoutSpinnerStates
@export var physics_states: ScoutPhysicsStates

@export_subgroup("Monitoring State Machines")
@export var targeting_states: ScoutTargetingStates

@export_subgroup("Behavior State Machines")
@export var behavior_states: ScoutBehaviorStates

@export_group("Movement Parameters")
@export var speed: float = 7.0
@export var targeting_speed: float = 3.5
@export var lerp_factor: float = 4.0

@onready var anim_state: AnimationNodeStateMachinePlayback = asset.anim_state

## Settable parameters
var in_left_nest: bool = false
var in_right_nest: bool = false

func _ready() -> void:
	Signals.debug_advance.connect(_on_debug_advance)


## Movement Controls
## ---------------------------------------
signal go_to_nest_finished(id: int)
func go_to_nest(nest: Enums.Direction, id: int = 0) -> void:
	## Select the nest to target and set it as the out of plane movement target
	movement_states.set_nest_as_out_of_plane_target(nest)
	
	## Engage out of plane movement
	sc.send_event(movement_states.TRANS_TO_OUT_OF_PLANE_MOVEMENT)
	
	## Await for the scout to be close enough to the next to begin "parking"
	await movement_states.enter_plane_ready
	sc.send_event(movement_states.TRANS_TO_ENTER_PLANE)
	
	## Once the scout is done parking, say so
	await movement_states.has_entered_plane
	go_to_nest_finished.emit(id)


## Engagement Controls
## ---------------------------------------
signal open_finished(id: int)
func open(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["idle", "thrust idle", "open", "quick open"]:
		sc.send_event(engagement_states.TRANS_TO_OPENING)
		await engagement_states.open_finished
	open_finished.emit(id)


signal quick_open_finished(id: int)
func quick_open(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["idle", "thrust idle", "quick open", "open"]:
		sc.send_event(engagement_states.TRANS_TO_QUICK_OPEN)
		await engagement_states.quick_open_finished
	quick_open_finished.emit(id)


signal close_finished(id: int)
func close(id: int = 0) -> void:
	if not anim_state.get_current_node() in ["closed", "close", "quick close"]:
		sc.send_event(engagement_states.TRANS_TO_CLOSING)
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
		sc.send_event(in_plane_movement_states.TRANS_TO_TARGET)
	return locked


func release_target() -> void:
	targeting_states.release_target()
	sc.send_event(in_plane_movement_states.TRANS_TO_MOVE)


## Spinner Controls
## ---------------------------------------
signal fire_finished(id: int)
func fire(id: int = 0) -> void:
	if anim_state.get_current_node() == "idle":
		sc.send_event(spinner_states.TRANS_TO_CHARGING)
		await spinner_states.fire_finished
		fire_finished.emit(id)
	else:
		fire_finished.emit(id)


## Damage Controls
## ---------------------------------------
func get_hit() -> void:
	## Nothing to do if scout is already incapacitated
	if health_states.state == ScoutHealthStates.State.INCAPACITATED:
		return
		
	## Close the scout quickly
	quick_close()
	
	## Turn rigid
	physics_states.set_initial_state(physics_states.State.RIGID)
	sc.send_event(health_states.TRANS_TO_INCAPACITATED)
	
	## Free the nests
	exit_nest()


## Hivemind interactions
## ---------------------------------------
func claim_nest(nest: Enums.Direction) -> bool:
	match(nest):
		Enums.Direction.LEFT:
			if not Representations.scout_hivemind_representation.scout_is_in_left_nest:
				in_left_nest = true
				Representations.scout_hivemind_representation.scout_is_in_left_nest = true
				return true
			return false
		Enums.Direction.RIGHT:
			if not Representations.scout_hivemind_representation.scout_is_in_right_nest:
				in_right_nest = true
				Representations.scout_hivemind_representation.scout_is_in_right_nest = true
				return true
			return false
		_:
			return false


func _identify_nearest_nest() -> Enums.Direction:
	var rel_x_to_player: float = movement_states.char_node.global_position.x - Representations.player_target_marker.global_position.x
	if rel_x_to_player > 0:
		return Enums.Direction.RIGHT
	return Enums.Direction.LEFT


## Returns the claimed nest, NONE if no nests claimed
func claim_nearest_nest() -> Enums.Direction:
	var nearest_nest: Enums.Direction = _identify_nearest_nest()
	if claim_nest(nearest_nest):
		return nearest_nest
	# If claiming the nearest nest fails, claim the other nest
	match(nearest_nest):
		Enums.Direction.LEFT:
			if claim_nest(Enums.Direction.RIGHT):
				return Enums.Direction.RIGHT
		Enums.Direction.RIGHT:
			if claim_nest(Enums.Direction.LEFT):
				return Enums.Direction.LEFT
	return Enums.Direction.NONE


func exit_nest() -> void:
	if in_left_nest:
		Representations.scout_hivemind_representation.scout_is_in_left_nest = false
		in_left_nest = false
	if in_right_nest:
		Representations.scout_hivemind_representation.scout_is_in_right_nest = false
		in_right_nest = false

#region debugging
func generate_state_report() -> String:
	var output: String = ""
	output += "Health : " + health_states.State.keys()[health_states.state] + "\n"
	output += "Movement : " + movement_states.State.keys()[movement_states.state] + "\n"
	output += "Orbiting : " + orbiting_states.State.keys()[orbiting_states.state] + "\n"
	output += "In-plane Movement : " + in_plane_movement_states.State.keys()[in_plane_movement_states.state] + "\n"
	output += "Engagement : " + engagement_states.State.keys()[engagement_states.state] + "\n"
	output += "Spinner : " + spinner_states.State.keys()[spinner_states.state] + "\n"
	output += "Physics : " + physics_states.State.keys()[physics_states.state] + "\n"
	output += "Targeting : " + targeting_states.State.keys()[targeting_states.state] + "\n"
	output += "Behavior : " + behavior_states.State.keys()[behavior_states.state] + "\n"
	output += "===================================\n"
	output += "Animation tree node: " + anim_state.get_current_node()\
			 + " (fading : " + anim_state.get_fading_from_node() + ")"
	return output


func _on_debug_advance() -> void:
	Signals.debug_log.emit(generate_state_report())
#endregion
