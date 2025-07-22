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
var player_detected: bool
var control_node_detected: bool

## Signals
signal player_proximity_entered
signal control_node_proximity_entered


# disabled state
#----------------------------------------
func _on_disabled_state_entered() -> void:
	state = State.DISABLED


# enabled state
#----------------------------------------
func _on_enabled_state_entered() -> void:
	state = State.ENABLED


func _on_enabled_state_physics_processing(delta: float) -> void:
	proximity_detector.force_shapecast_update()
	if proximity_detector.is_colliding():
		for i in range(proximity_detector.get_collision_count()):
			var collider: Object = proximity_detector.get_collider(i)
			
			## Scan for the control node entering the shapecast
			if scan_for_control_node and collider.get_parent() is ControlNode:
				if not control_node_detected:
					control_node_proximity_entered.emit()
					control_node_detected = true
			
			## Scan for the player entering the shapecast
			if scan_for_player and collider is Player3D:
				if not player_detected:
					drone.targeting_states.target = collider
					player_proximity_entered.emit()
					player_detected = true
	else:
		control_node_detected = false
		player_detected = false
