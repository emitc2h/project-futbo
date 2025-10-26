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


func _ready() -> void:
	super._ready()
	control_node = ball as ControlNode
	control_node.asset.warp_out_finished.connect(_on_warp_out_finished)
	control_node.asset.warp_effect.materialized_finished.connect(_on_warp_in_finished)
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


#=======================================================
# RECEIVED SIGNALS
#=======================================================
func _on_warp_out_finished() -> void:
	update_position_to_warp_destination = true
	control_node.asset.warp_in()


func _on_warp_in_finished() -> void:
	sc.send_event(TRANS_TO_RIGID)


func _on_player_update_destination(pos: Vector3) -> void:
	warp_destination = pos
