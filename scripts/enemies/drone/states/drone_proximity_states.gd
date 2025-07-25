class_name DroneProximityStates
extends Node

## Dependency Injection
@export_group("Dependencies")
@export var drone: Drone
@export var sc: StateChart
@export var proximity_detector: ShapeCast3D
@export var repr: DroneInternalRepresentation

## Parameters
@export_group("Parameters")
@export var scan_for_player: bool = true
@export var scan_for_control_node: bool = true

## States Enum
enum State {DISABLED = 0, ENABLED = 1}
var state: State = State.ENABLED

## State transition constants
const TRANS_DISABLED_TO_ENABLED: String = "Proximity: disabled to enabled"
const TRANS_ENABLED_TO_DISABLED: String = "Proximity: enabled to disabled"

## Internal variables
var control_node_in_detector: bool = false
var player_in_detector: bool = false

## Signals
signal player_proximity_entered
signal player_proximity_exited
signal control_node_proximity_entered
signal control_node_proximity_exited


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	state = State.DISABLED


# enabled state
#----------------------------------------
func _on_enabled_state_entered() -> void:
	state = State.ENABLED


func _on_enabled_state_physics_processing(delta: float) -> void:
	var control_node_entered_confirmed: bool = false
	var player_entered_confirmed: bool = false
	
	proximity_detector.force_shapecast_update()
	if proximity_detector.is_colliding():
		for i in range(proximity_detector.get_collision_count()):
			var collider: Object = proximity_detector.get_collider(i)
			
			## Scan for the control node entering the shapecast
			if scan_for_control_node and collider.get_parent() is ControlNode:
				control_node_entered_confirmed = true
			
			## Scan for the player entering the shapecast
			if scan_for_player and collider is Player3D:
				player_entered_confirmed = true
		
		if control_node_entered_confirmed and not control_node_in_detector:
			control_node_proximity_entered.emit()
			control_node_in_detector = true

		if player_entered_confirmed and not player_in_detector:
			player_proximity_entered.emit()
			player_in_detector = true
			
	if not control_node_entered_confirmed and control_node_in_detector:
		control_node_proximity_exited.emit()
		control_node_in_detector = false
		
	if not player_entered_confirmed and player_in_detector:
		player_proximity_exited.emit()
		player_in_detector = false
