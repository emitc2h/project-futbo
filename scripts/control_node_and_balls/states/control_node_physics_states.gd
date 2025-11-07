class_name ControlNodePhysicsStates
extends BallPhysicsStates

## Overrides
var control_node: ControlNode

## Settable parameters
var warp_destination: Vector3
var update_position_to_warp_destination: bool

## States Enum
# Additional states introduced by this extended class are added to the base class since enums can't
# be directly extended. Those states just aren't used in the base class.

## State transition constants
const TRANS_TO_WARPING: String = "Physics: to warping"

## Animation constants
const WARP_OUT_ANIMATION: String = "transition - warp out"
const WARP_IN_ANIMATION: String = "transition - warp in"

func _ready() -> void:
	super._ready()
	control_node = ball as ControlNode
	Signals.player_update_destination.connect(_on_player_update_destination)


# warping state
#----------------------------------------
func _on_warping_state_entered() -> void:
	state = State.WARPING
	update_position_to_warp_destination = false


func _on_warping_state_physics_processing(_delta: float) -> void:
	if update_position_to_warp_destination:
		Signals.control_node_requests_destination.emit()
		track_transform_container.global_position = warp_destination
		track_position_container.global_position = warp_destination
		char_node.global_position = warp_destination
		rigid_node.global_position = warp_destination


func _on_warping_state_exited() -> void:
	pass


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_player_update_destination(pos: Vector3) -> void:
	warp_destination = pos


func _on_animation_state_finished(anim_name: String) -> void:
	match(anim_name):
		WARP_OUT_ANIMATION:
			sc.send_event(TRANS_TO_RIGID)
			sc.send_event(control_node.power_states.TRANS_TO_CHARGING)
		WARP_IN_ANIMATION:
			sc.send_event(TRANS_TO_WARPING)
			update_position_to_warp_destination = true
			control_node.anim_state.travel(WARP_OUT_ANIMATION)


#=======================================================
# CONTROLS
#=======================================================
func warp() -> void:
	control_node.anim_state.travel(WARP_IN_ANIMATION)
