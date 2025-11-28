class_name TrackTargetAction
extends BTAction

@export_group("Parameters")
@export var default_offset: float = 5.0
@export var cautious_offset: float = 8.0

var drone: Drone
var is_cautious: bool = false
var done: bool = false


func _setup() -> void:
	drone = agent as Drone
	Signals.control_node_is_charged.connect(_on_control_node_is_charged)
	Signals.control_node_is_discharged.connect(_on_control_node_is_discharged)
	drone.proximity_states.player_proximity_entered.connect(_on_player_proximity_entered)


func _enter() -> void:
	done = false


func _tick(delta: float) -> Status:
	var offset: float
	match(is_cautious):
		true:
			offset = cautious_offset
		false:
			offset = default_offset
	
	drone.track_target(offset, delta)
	
	if done:
		return SUCCESS
	
	return RUNNING


func _on_control_node_is_charged() -> void:
	is_cautious = true


func _on_control_node_is_discharged() -> void:
	is_cautious = false


func _on_player_proximity_entered() -> void:
	done = true
