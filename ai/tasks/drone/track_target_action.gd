class_name TrackTargetAction
extends BTAction

@export_group("Parameters")
@export var default_offset: float = 5.0
@export var cautious_offset: float = 8.0

var drone: Drone
var is_cautious: bool = false


func _setup() -> void:
	drone = agent as Drone
	Signals.control_node_is_charged.connect(_on_control_node_is_charged)
	Signals.control_node_is_discharged.connect(_on_control_node_is_discharged)


func _tick(delta: float) -> Status:
	var offset: float
	match(is_cautious):
		true:
			offset = cautious_offset
		false:
			offset = default_offset
	
	drone.track_target(offset, delta)
	return RUNNING


func _on_control_node_is_charged() -> void:
	is_cautious = true


func _on_control_node_is_discharged() -> void:
	is_cautious = false
