class_name ControlNodeAttractorStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var control_node: ControlNode
@export var sc: StateChart

@export_group("Parameters")
@export var attractor_force: float = 1000.0

@onready var timer: Timer = $Timer

## States Enum
enum State {DISABLED = 0, ENABLED = 1}
var state: State = State.ENABLED

## State transition constants
const TRANS_TO_ENABLED: String = "Attractor: to enabled"
const TRANS_TO_DISABLED: String = "Attractor: to disabled"

var do_apply_force: bool = false
var attractor_pos: Vector3

func _ready() -> void:
	Signals.control_node_attractor.connect(_on_control_node_attractor)


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	state = State.DISABLED
	timer.start()


# enabled state
#----------------------------------------
func _on_enabled_state_entered() -> void:
	state = State.ENABLED
	timer.stop()


func _on_enabled_state_physics_processing(delta: float) -> void:
	if do_apply_force:
		var force_direction: Vector3 = (attractor_pos - control_node.control_node_physics_states.rigid_node.global_position).normalized()
		control_node.control_node_physics_states.rigid_node.apply_central_force(delta * force_direction * attractor_force)
		do_apply_force = false


#=======================================================
# SIGNALS
#=======================================================
func _on_timer_timeout() -> void:
	sc.send_event(TRANS_TO_ENABLED)


func _on_control_node_attractor(destination: Vector3) -> void:
	if not control_node.power_states.state == control_node.power_states.State.ON:
		return
	
	if not control_node.control_node_physics_states.state == control_node.control_node_physics_states.State.RIGID:
		return
	
	do_apply_force = true
	attractor_pos = destination


#=======================================================
# CONTROLS
#=======================================================
func enable() -> void:
	sc.send_event(TRANS_TO_ENABLED)


func disable() -> void:
	sc.send_event(TRANS_TO_DISABLED)
